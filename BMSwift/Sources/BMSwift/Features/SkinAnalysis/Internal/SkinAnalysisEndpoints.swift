#if canImport(UIKit) && os(iOS)
import Foundation
import UIKit

/// Endpoints for the Skin Analysis feature
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Analyze skin endpoint
    public struct AnalyzeSkin: BMNetwork.APIEndpoint {
        public typealias RequestType = RapidAPI.AnalyzeRequest
        public typealias ResponseType = RapidAPI.Response
        
        public let path: String
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        public let headers: [String: String]
        public let baseURL: URL?
        
        public let imageUrl: String
        
        public init(imageUrl: String) {
            self.imageUrl = imageUrl
            self.path = "/analyze"
            self.headers = RapidAPIConfig.configuration.defaultHeaders
            self.baseURL = RapidAPIConfig.configuration.baseURL
        }
    }
}

// MARK: - Factory Methods
public extension SkinAnalysisEndpoints {
    static func analyzeSkin(imageUrl: String) -> BMNetwork.APIRequest<AnalyzeSkin> {
        let endpoint = AnalyzeSkin(imageUrl: imageUrl)
        let body = RapidAPI.AnalyzeRequest(imageUrl: imageUrl)
        return BMNetwork.APIRequest(endpoint: endpoint, body: body)
    }
}

#endif
