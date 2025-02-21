import Foundation
import AVFoundation

@MainActor final class VoiceSearchViewModel: NSObject, ObservableObject {
    enum VoiceSearchState: Equatable {
        case idle
        case recording
        case processing
        case searching(isLoadingMore: Bool)
        case error(VoiceError)
        
        static func == (lhs: VoiceSearchState, rhs: VoiceSearchState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.recording, .recording),
                 (.processing, .processing):
                return true
            case (.searching(let l), .searching(let r)):
                return l == r
            case (.error(let l), .error(let r)):
                return l.localizedDescription == r.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum VoiceError: LocalizedError {
        case recordingFailed(Error)
        case transcriptionFailed(Error)
        case searchFailed(Error)
        case noSpeechDetected
        
        var errorDescription: String? {
            switch self {
            case .recordingFailed(let error):
                return "錄音失敗: \(error.localizedDescription)"
            case .transcriptionFailed(let error):
                return "語音辨識失敗: \(error.localizedDescription)"
            case .searchFailed(let error):
                return "搜尋失敗: \(error.localizedDescription)"
            case .noSpeechDetected:
                return "無法辨識您的語音"
            }
        }
    }
    
    // MARK: - Pagination State
    private var currentPage = 0
    private var lastPage = 1
    private var isLoadingMore = false
    private var lastSearchText: String?
    
    public var canLoadMore: Bool {
        currentPage < lastPage && lastSearchText != nil
    }
    
    @Published private(set) var state: VoiceSearchState = .idle
    @Published private(set) var transcribedText: String?
    
    private let voiceSearchService: VoiceSearchServiceProtocol
    private let transcriptionService: VoiceTranscriptionServiceProtocol
    private let conversationService: ConversationServiceProtocol
    private let encyclopediaViewModel: EncyclopediaViewModel
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let token: String
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    init(
        service: VoiceSearchServiceProtocol = VoiceSearchService(),
        transcriptionService: VoiceTranscriptionServiceProtocol = VoiceTranscriptionService(),
        conversationService: ConversationServiceProtocol = ConversationService(),
        encyclopediaViewModel: EncyclopediaViewModel,
        token: String
    ) {
        self.voiceSearchService = service
        self.transcriptionService = transcriptionService
        self.conversationService = conversationService
        self.encyclopediaViewModel = encyclopediaViewModel
        self.token = token
        super.init()
        setupAudioSession()
        
        // Observe load more notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoadMore), name: .loadMoreResults, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleLoadMore(_ notification: Notification) {
        // Extract source from notification
        let source = notification.userInfo?["source"] as? EncyclopediaViewModel.SearchSource
        
        // Only proceed if this is a voice search notification
        guard source == .voice else {
            print("[VoiceSearch] Skipping notification: source=\(source?.description ?? "none")")
            return
        }
        
        // Handle the load more request
        print("[VoiceSearch] Loading more results")
        Task {
            do {
                try await performSearch(loadMore: true)
            } catch {
                state = .error(.searchFailed(error))
            }
        }
    }
    
    @MainActor private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            state = .error(.recordingFailed(error))
        }
    }
    
    private func speakResponse(_ response: String) {
        let utterance = AVSpeechUtterance(string: response)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
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
            let voiceError = VoiceError.recordingFailed(error)
            state = .error(voiceError)
            throw voiceError
        }
    }
    
    @MainActor func stopRecordingAndSearch() async {
        guard let recorder = audioRecorder, let recordingURL = recordingURL else {
            state = .error(.noSpeechDetected)
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
            
            // Update transcribed text
            self.transcribedText = speechText
            
            // Store search text for pagination
            lastSearchText = speechText
            currentPage = 1
            lastPage = 1
            
            // First get conversation response and speak it
            do {
                let response = try await conversationService.getResponse(for: speechText)
                speakResponse(response.ans)
            } catch {
                print("Failed to get conversation response: \(error)")
                // Continue even if conversation fails
            }
            
            // Then perform search
            try await performSearch(loadMore: false)
        } catch {
            let nsError = error as NSError
            if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1110 {
                print("[VoiceSearch] No speech detected in transcription, resetting to idle state")
                state = .idle
            } else {
                state = .error(.transcriptionFailed(error))
            }
        }
    }
    
    @MainActor func performSearch(loadMore: Bool = false) async throws {
        guard let searchText = lastSearchText else {
            print("[VoiceSearch] No speech text available, resetting to idle state")
            state = .idle
            return
        }
        
        print("[VoiceSearch] Starting search - text: \(searchText), loadMore: \(loadMore)")
        print("[VoiceSearch] Current state - page: \(currentPage), lastPage: \(lastPage), isLoadingMore: \(isLoadingMore)")
        
        // Don't allow concurrent loading
        guard !isLoadingMore else {
            print("[VoiceSearch] Already loading more results")
            return
        }
        
        // Only reset pagination for new searches
        if !loadMore {
            print("[VoiceSearch] New search - resetting pagination")
            currentPage = 1  // Start at page 1 to match API
            lastPage = 1
            encyclopediaViewModel.clearSearchResults()
            encyclopediaViewModel.updateSearchSource(.voice)
        } else {
            print("[VoiceSearch] Loading more - keeping pagination state")
        }
        
        let nextPage = currentPage + 1
        print("[VoiceSearch] Requesting page \(nextPage)")
        state = .searching(isLoadingMore: loadMore)
        isLoadingMore = true
        
        do {
            // Perform voice search with transcribed text
            let searchResults = try await voiceSearchService.searchByVoice(
                voiceText: searchText,
                type: 0,  // Default to all types
                page: nextPage,
                authToken: token
            )
            
            // Update pagination state
            currentPage = searchResults.contents.currentPage
            lastPage = searchResults.contents.lastPage
            
            // Get search articles directly from response
            let searchArticles = searchResults.contents.data
            
            // Update encyclopedia view model
            encyclopediaViewModel.updateWithSearchResults(
                searchArticles,
                page: searchResults.contents.currentPage,
                lastPage: searchResults.contents.lastPage,
                append: loadMore,
                totalArticles: searchResults.contents.total,
                searchKeyword: searchText
            )
            
            state = .idle
            isLoadingMore = false
        } catch {
            state = .error(.searchFailed(error))
            isLoadingMore = false
        }
        }
    }

extension VoiceSearchViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                state = .error(.recordingFailed(NSError(domain: "VoiceSearch", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recording failed"])))
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            Task { @MainActor in
                state = .error(.recordingFailed(error))
            }
        }
    }
}