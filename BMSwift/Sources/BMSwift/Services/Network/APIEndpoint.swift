#if canImport(SwiftUI) && os(iOS)
import Foundation

public struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let body: Encodable?
    
    public init(
        path: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Encodable? = nil
    ) {
        self.path = path
        self.method = method
        
        // Merge default headers with custom headers
        var defaultHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        headers.forEach { defaultHeaders[$0.key] = $0.value }
        self.headers = defaultHeaders
        
        self.body = body
    }
}

public struct APIErrorResponse: Codable {
    let error: String
}
#endif
