import Foundation
import AVFoundation

@MainActor final class VoiceSearchViewModel: NSObject, ObservableObject {
    enum VoiceSearchState {
        case idle
        case recording
        case processing
        case error(Error)
    }
    
    @Published private(set) var state: VoiceSearchState = .idle
    private let voiceSearchService: VoiceSearchServiceProtocol
    private let transcriptionService: VoiceTranscriptionServiceProtocol
    private let encyclopediaViewModel: EncyclopediaViewModel
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let token: String
    
    init(
        service: VoiceSearchServiceProtocol = VoiceSearchService(),
        transcriptionService: VoiceTranscriptionServiceProtocol = VoiceTranscriptionService(),
        encyclopediaViewModel: EncyclopediaViewModel,
        token: String
    ) {
        self.voiceSearchService = service
        self.transcriptionService = transcriptionService
        self.encyclopediaViewModel = encyclopediaViewModel
        self.token = token
        super.init()
        setupAudioSession()
    }
    
    @MainActor private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            state = .error(error)
        }
    }
    
    @MainActor func startRecording() async throws {
        // Create temporary URL for recording
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("voice_search.m4a")
        
        // Setup audio recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            recordingURL = audioFilename
            state = .recording
        } catch {
            state = .error(error)
            throw error
        }
    }
    
    @MainActor func stopRecordingAndSearch() async {
        guard let recorder = audioRecorder, let recordingURL = recordingURL else {
            state = .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No recording available"]))
            return
        }
        
        recorder.stop()
        audioRecorder = nil
        state = .processing
        
        do {
            // Get the speech text
            print("DEBUG: Starting transcription of audio at \(recordingURL)")
            let speechText = try await transcriptionService.transcribe(audioURL: recordingURL, authToken: token)
            print("DEBUG: Got speech text: \(speechText)")
            
            // Perform voice search with transcribed text
            let searchResults = try await voiceSearchService.searchByVoice(voiceText: speechText)
            
            // Convert voice search articles to regular search articles
            let searchArticles = searchResults.contents.data.map { voiceArticle in
                Search.SearchArticle(
                    id: voiceArticle.id,
                    title: voiceArticle.title,
                    intro: voiceArticle.intro,
                    mediaName: voiceArticle.mediaName,
                    visitCount: voiceArticle.visitCount,
                    likeCount: voiceArticle.likeCount,
                    firstEnabledAt: voiceArticle.firstEnabledAt,
                    hashtags: [],  // Voice search doesn't provide hashtags
                    typeType: nil,
                    typeTitle: nil,
                    typeContent: nil
                )
            }
            
            // Update encyclopedia view model with converted search results
            encyclopediaViewModel.updateWithSearchResults(searchArticles)
            state = .idle
            
        } catch {
            state = .error(error)
        }
    }
}

extension VoiceSearchViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                state = .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording failed"]))
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            Task { @MainActor in
                state = .error(error)
            }
        }
    }
}
