#if canImport(SwiftUI) && os(iOS)
import Foundation

public enum NetworkError: LocalizedError, Codable {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case apiError(String)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let message = try container.decode(String.self, forKey: .message)
        self = .apiError(message)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .apiError(let message), .serverError(let message):
            try container.encode("error", forKey: .type)
            try container.encode(message, forKey: .message)
        default:
            try container.encode("error", forKey: .type)
            try container.encode(localizedDescription, forKey: .message)
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .apiError(let message):
            return message
        }
    }
}
#endif
