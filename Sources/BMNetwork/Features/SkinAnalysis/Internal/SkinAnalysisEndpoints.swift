#if canImport(SwiftUI) && os(iOS)
import Foundation

// MARK: - Base Protocol
public protocol SkinAnalysisEndpoint: BMNetwork.APIEndpoint {}

public extension SkinAnalysisEndpoint {
    var baseURL: URL? {
        URL(string: "https://face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com")
    }
    
    var isExternalAPI: Bool { true }
    
    static var rapidAPIKey: String { "YOUR-RAPIDAPI-KEY" }
    static var rapidAPIHost: String { "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com" }
    
    var headers: [String: String] {
        [
            "X-RapidAPI-Key": Self.rapidAPIKey,
            "X-RapidAPI-Host": Self.rapidAPIHost
        ]
    }
}

/// Endpoints for the Skin Analysis feature
public enum SkinAnalysisEndpoints {
    /// Check endpoint for skin analysis
    public struct Check: SkinAnalysisEndpoint {
        public typealias RequestType = BMNetwork.EmptyRequest
        public typealias ResponseType = SkinAnalysisResponse
        
        public let path: String = "/check"
        public let method: BMNetwork.HTTPMethod = .post
        public let body: Data?
        private let customHeaders: [String: String]
        
        public var headers: [String: String] {
            var baseHeaders = [
                "Content-Type": "multipart/form-data; boundary=\(boundary)",
                "X-RapidAPI-Key": Self.rapidAPIKey,
                "X-RapidAPI-Host": Self.rapidAPIHost
            ]
            baseHeaders.merge(customHeaders) { current, _ in current }
            return baseHeaders
        }
        
        private let boundary: String
        
        public init(imageData: Data, language: String = "en", noqueue: Bool = true) {
            self.boundary = UUID().uuidString
            self.customHeaders = [:]
            
            var data = Data()
            
            // Add image data
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
            data.append("Content-Type: image/jpeg\r\n\r\n")
            data.append(imageData)
            data.append("\r\n")
            
            // Add language parameter
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n")
            data.append("\(language)\r\n")
            
            // Add noqueue parameter
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"noqueue\"\r\n\r\n")
            data.append("\(noqueue)\r\n")
            
            // Add final boundary
            data.append("--\(boundary)--\r\n")
            
            self.body = data
        }
    }
    
    /// Analyze endpoint for skin analysis
    public struct Analyze: SkinAnalysisEndpoint {
        public typealias RequestType = BMNetwork.EmptyRequest
        public typealias ResponseType = SkinAnalysisResponse
        
        public let path: String = "/analyze"
        public let method: BMNetwork.HTTPMethod = .post
        public let body: Data?
        private let customHeaders: [String: String]
        
        public var headers: [String: String] {
            var baseHeaders = [
                "Content-Type": "multipart/form-data; boundary=\(boundary)",
                "X-RapidAPI-Key": Self.rapidAPIKey,
                "X-RapidAPI-Host": Self.rapidAPIHost
            ]
            baseHeaders.merge(customHeaders) { current, _ in current }
            return baseHeaders
        }
        
        private let boundary: String
        
        public init(imageData: Data, language: String = "en", noqueue: Bool = true) {
            self.boundary = UUID().uuidString
            self.customHeaders = [:]
            
            var data = Data()
            
            // Add image data
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
            data.append("Content-Type: image/jpeg\r\n\r\n")
            data.append(imageData)
            data.append("\r\n")
            
            // Add language parameter
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n")
            data.append("\(language)\r\n")
            
            // Add noqueue parameter
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"noqueue\"\r\n\r\n")
            data.append("\(noqueue)\r\n")
            
            // Add final boundary
            data.append("--\(boundary)--\r\n")
            
            self.body = data
        }
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// MARK: - Factory Methods
public extension SkinAnalysisEndpoints {
    static func check(imageData: Data, language: String = "en", noqueue: Bool = true) -> BMNetwork.APIRequest<Check> {
        BMNetwork.APIRequest(endpoint: Check(imageData: imageData, language: language, noqueue: noqueue))
    }
    
    static func analyze(imageData: Data, language: String = "en", noqueue: Bool = true) -> BMNetwork.APIRequest<Analyze> {
        BMNetwork.APIRequest(endpoint: Analyze(imageData: imageData, language: language, noqueue: noqueue))
    }
}
#endif
