#if canImport(SwiftUI) && os(iOS)
import Foundation

/// HTTP method types supported by the API
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
#endif
