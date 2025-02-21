import Foundation
import AVFoundation

@MainActor final class VoiceSearchViewModel: NSObject, ObservableObject {
    enum VoiceSearchState {
        case idle
        case recording
        case processing
        case searching
        case error(Error)
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
    @Published private(set) var conversationResponse: String?
    @Published private(set) var isExpandedResponse: Bool = false
    
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
            await performSearch(loadMore: true)
        }
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
            
            // Stop any ongoing speech
            speechSynthesizer.stopSpeaking(at: .immediate)
            
            // If no speech was detected, reset state and show error
            if speechText.isEmpty {
                state = .error(NSError(
                    domain: "kAFAssistantErrorDomain",
                    code: 1110,
                    userInfo: [NSLocalizedDescriptionKey: "無法辨識您的語音"]
                ))
                
                // Reset after a short delay to allow error to be shown
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    if case .error = state {
                        state = .idle
                    }
                }
                return
            }
            
            // Store search text for pagination
            lastSearchText = speechText
            currentPage = 1  // Start at page 1 to match API
            lastPage = 1
            
            // Start both conversation and search tasks
            async let searchTask = performSearch(loadMore: false)
            await getConversationResponse(for: speechText)
            
            // Wait for search to complete
            try await searchTask
            
            // Update encyclopedia view model with converted search results
        } catch {
            // Reset state after a short delay for any error
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                if case .error = state {
                    state = .idle
                }
            }
            state = .error(error)
        }
    }
    
    @MainActor func performSearch(loadMore: Bool = false) async {
        guard let searchText = lastSearchText else {
            state = .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No search text available"]))
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
        state = .searching
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
                totalArticles: searchResults.contents.total
            )
            
            state = .idle
            isLoadingMore = false
        } catch {
            state = .error(error)
            isLoadingMore = false
        }
        }
    }

    @MainActor private func getConversationResponse(for text: String) async {
        do {
            // Get conversation response
            let response = try await conversationService.getResponse(for: text)
            conversationResponse = response.ans
            
            // Configure speech synthesis
            let utterance = AVSpeechUtterance(string: response.ans)
            if let voice = AVSpeechSynthesisVoice(language: "zh-TW") {
                utterance.voice = voice
                utterance.rate = 0.45  // Slower rate for better clarity
                utterance.pitchMultiplier = 1.2 // Slightly higher pitch for female voice
                
                // Speak the response
                speechSynthesizer.speak(utterance)
            }
        } catch {
            print("Conversation error: \(error)")
            // Don't throw the error as we want search to continue even if conversation fails
        }
    }
    
    func toggleResponseExpansion() {
        isExpandedResponse.toggle()
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
