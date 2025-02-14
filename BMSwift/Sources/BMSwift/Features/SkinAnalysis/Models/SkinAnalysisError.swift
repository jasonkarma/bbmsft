#if canImport(UIKit) && os(iOS)
import Foundation

public enum SkinAnalysisError: LocalizedError, Equatable {
    case cameraSetupError
    case cameraError(Error)
    case imageProcessingError
    case invalidImage
    case failedToAnalyze
    case unknown(Error)
    case networkError(Error)
    case imageCompressionFailed
    case permissionDenied
    case cameraUnavailable
    case analysisError(String)
    case imageTooLarge(Double)
    case invalidResponse
    case invalidSpecification
    case invalidAspectRatio(CGFloat)
    case requestInProgress
    case concurrencyLimitExceeded
    
    public var errorDescription: String? {
        switch self {
        case .cameraSetupError:
            return "Failed to setup camera"
        case .cameraError(let error):
            return "Camera error: \(error.localizedDescription)"
        case .imageProcessingError:
            return "Failed to process captured image"
        case .invalidImage:
            return "Invalid image data"
        case .failedToAnalyze:
            return "Failed to analyze skin"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .imageCompressionFailed:
            return "Failed to compress the image"
        case .permissionDenied:
            return "Camera access permission denied"
        case .cameraUnavailable:
            return "Camera is unavailable"
        case .analysisError(let message):
            return message
        case .imageTooLarge(let size):
            return "The image size is too large (\(String(format: "%.1f", size))MB)"
        case .invalidResponse:
            return "Received invalid response from server"
        case .invalidSpecification:
            return "Invalid analysis specification"
        case .concurrencyLimitExceeded:
            return "Too many requests. Please try again in a moment."
        case .invalidAspectRatio(let ratio):
            return "Invalid aspect ratio: \(String(format: "%.2f", ratio))"
        case .requestInProgress:
            return "請稍候，正在處理上一個請求"
        }
    }
    
    public static func == (lhs: SkinAnalysisError, rhs: SkinAnalysisError) -> Bool {
        switch (lhs, rhs) {
        case (.cameraSetupError, .cameraSetupError),
             (.imageProcessingError, .imageProcessingError),
             (.invalidImage, .invalidImage),
             (.failedToAnalyze, .failedToAnalyze),
             (.imageCompressionFailed, .imageCompressionFailed),
             (.permissionDenied, .permissionDenied),
             (.cameraUnavailable, .cameraUnavailable),
             (.invalidResponse, .invalidResponse),
             (.invalidSpecification, .invalidSpecification),
             (.requestInProgress, .requestInProgress):
            return true
        case (.cameraError(let lhsError), .cameraError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.analysisError(let lhsMessage), .analysisError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.imageTooLarge(let lhsSize), .imageTooLarge(let rhsSize)):
            return lhsSize == rhsSize
        case (.invalidAspectRatio(let lhsRatio), .invalidAspectRatio(let rhsRatio)):
            return lhsRatio == rhsRatio
        default:
            return false
        }
    }
}

#endif
