import Foundation
import AVFoundation

@MainActor
final class ConversationViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case success
        case error(Error)
    }
    
    // MARK: - Published Properties
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var response: String?
    @Published private(set) var isExpanded: Bool = false
    
    // MARK: - Private Properties
    private let service: ConversationServiceProtocol
    private let speechSynthesizer: AVSpeechSynthesizer
    
    // MARK: - Initialization
    init(service: ConversationServiceProtocol = ConversationService()) {
        self.service = service
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    // MARK: - Public Methods
    func getResponse(for text: String) async {
        state = .loading
        
        do {
            // Stop any ongoing speech
            speechSynthesizer.stopSpeaking(at: .immediate)
            
            // Get conversation response
            let response = try await service.getResponse(for: text)
            self.response = response.ans
            
            // Configure speech synthesis
            let utterance = AVSpeechUtterance(string: response.ans)
            if let voice = AVSpeechSynthesisVoice(language: "zh-TW") {
                utterance.voice = voice
                utterance.rate = 0.45  // Slower rate for better clarity
                utterance.pitchMultiplier = 1.2 // Slightly higher pitch for female voice
                
                // Speak the response
                speechSynthesizer.speak(utterance)
            }
            
            state = .success
        } catch {
            print("Conversation error: \(error)")
            state = .error(error)
        }
    }
    
    func toggleResponseExpansion() {
        isExpanded.toggle()
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}
