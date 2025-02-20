import Foundation
import AVFoundation

/// Service responsible for recording voice and managing audio session
@MainActor final class VoiceRecordingService: NSObject, AVAudioRecorderDelegate {
    private let queue = DispatchQueue(label: "com.bmswift.voicerecording", attributes: .concurrent)
    private let stateQueue = DispatchQueue(label: "com.bmswift.voicerecording.state")
    
    enum RecordingState: Equatable {
        static func == (lhs: VoiceRecordingService.RecordingState, rhs: VoiceRecordingService.RecordingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.recording, .recording), (.processing, .processing):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
        case idle
        case recording
        case processing
        case error(Error)
    }
    
    enum VoiceRecordingError: LocalizedError {
        case recordingInProgress
        case noRecordingAvailable
        case recordingFailed(Error)
        case microphonePermissionDenied
        case audioSessionError(Error)
        case transcriptionFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .recordingInProgress:
                return "Recording already in progress"
            case .noRecordingAvailable:
                return "No recording available"
            case .recordingFailed(let error):
                return "Recording failed: \(error.localizedDescription)"
            case .microphonePermissionDenied:
                return "請允許麥克風權限來進行語音搜尋"
            case .audioSessionError(let error):
                return "Audio session error: \(error.localizedDescription)"
            case .transcriptionFailed(let error):
                return "Failed to transcribe audio: \(error.localizedDescription)"
            }
        }
    }
    
    private var _state: RecordingState = .idle
    private var state: RecordingState {
        get { stateQueue.sync { _state } }
        set { stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    override init() {
        super.init()
        Task {
            do {
                try await setupAudioSession()
            } catch {
                self.state = .error(VoiceRecordingError.audioSessionError(error))
            }
        }
    }
    
    private func setupAudioSession() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        
        // Request microphone permission
        switch session.recordPermission {
        case .undetermined:
            let granted = await withCheckedContinuation { continuation in
                session.requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }
            if !granted {
                throw VoiceRecordingError.microphonePermissionDenied
            }
        case .denied:
            throw VoiceRecordingError.microphonePermissionDenied
        case .granted:
            break
        @unknown default:
            throw VoiceRecordingError.microphonePermissionDenied
        }
        
        try session.setActive(true)
    }
    
    func startRecording() async throws {
        guard state == .idle else {
            throw VoiceRecordingError.recordingInProgress
        }
        
        // Create temporary URL for recording
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording.m4a")
        
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
            self.state = .recording
        } catch {
            self.state = .error(VoiceRecordingError.recordingFailed(error))
            throw VoiceRecordingError.recordingFailed(error)
        }
    }
    
    func stopRecording() async throws -> URL {
        guard let recorder = audioRecorder, let url = recordingURL else {
            throw VoiceRecordingError.noRecordingAvailable
        }
        
        recorder.stop()
        audioRecorder = nil
        self.state = .idle
        return url
    }
}

extension VoiceRecordingService {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                self.state = .error(VoiceRecordingError.recordingFailed(NSError(domain: "", code: -1, userInfo: nil)))
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            Task { @MainActor in
                self.state = .error(VoiceRecordingError.recordingFailed(error))
            }
        }
    }
}
