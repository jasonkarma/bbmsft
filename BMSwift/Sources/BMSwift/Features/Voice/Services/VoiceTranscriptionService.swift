import Foundation
import Speech

/// Service responsible for transcribing voice recordings using local speech recognition
protocol VoiceTranscriptionServiceProtocol {
    func transcribe(audioURL: URL, authToken: String) async throws -> String
}

final class VoiceTranscriptionService: VoiceTranscriptionServiceProtocol {
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        // Initialize with Chinese (Traditional) recognizer
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
    }
    
    func transcribe(audioURL: URL, authToken: String) async throws -> String {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("DEBUG: Speech recognizer not available")
            throw NSError(domain: "VoiceTranscription", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition is not available"])
        }
        
        print("DEBUG: Starting speech recognition for audio at \(audioURL)")
        
        // Create recognition request
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false
        
        // Perform recognition
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    print("DEBUG: Speech recognition error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result else {
                    print("DEBUG: No speech recognition result available")
                    continuation.resume(throwing: NSError(domain: "VoiceTranscription", code: -2, userInfo: [NSLocalizedDescriptionKey: "No result available"]))
                    return
                }
                
                if result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    print("DEBUG: Final transcription: \(transcription)")
                    continuation.resume(returning: transcription)
                } else {
                    print("DEBUG: Partial transcription: \(result.bestTranscription.formattedString)")
                }
            }
        }
    }
}
