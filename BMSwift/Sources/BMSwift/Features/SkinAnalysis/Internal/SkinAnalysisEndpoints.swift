#if canImport(UIKit) && os(iOS)
import Foundation

/// Endpoints for the Skin Analysis feature.
/// Provides endpoints for analyzing skin images using RapidAPI's face analysis service.
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Endpoint for analyzing skin images.
    /// This endpoint sends image data to RapidAPI's face analysis service and receives detailed analysis results.
    public struct Analyze: BMNetwork.APIEndpoint {
        public typealias RequestType = Request
        public typealias ResponseType = SkinAnalysisModels.Response
        
        public let path: String = "/check"
        public let method: BMNetwork.HTTPMethod = .post
        
        public var baseURL: URL? { URL(string: "https://face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com") }
        
        public var headers: [String: String] {
            var headers = [
                "x-rapidapi-key": "0fc47de525mshb9e37b660469c06p1c82b4jsnc54f0234e207",
                "x-rapidapi-host": "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com",
                "Accept": "application/json"
            ]
            
            // For URL method, set Content-Type to false
            // For image upload, use application/json
            if request.imageUrl != nil {
                headers["Content-Type"] = "false"
                print("DEBUG: Using URL method with Content-Type: false")
            } else if request.image != nil {
                headers["Content-Type"] = "application/json"
                print("DEBUG: Using application/json for image upload")
            }
            
            print("DEBUG: Headers being sent:")
            headers.forEach { key, value in
                print("  \(key): \(value)")
            }
            
            return headers
        }
        
        public struct Request: Encodable {
            let imageUrl: String?
            let image: Data?
            let lang: String
            let noqueue: Int
            
            private enum CodingKeys: String, CodingKey {
                case imageUrl
                case image
                case lang
                case noqueue
            }
            
            public init(imageUrl: String? = nil, image: Data? = nil, lang: String = "en", noqueue: Int = 1) {
                self.imageUrl = imageUrl
                self.image = image
                self.lang = lang
                self.noqueue = noqueue
                
                print("DEBUG: Request initialized with:")
                print("- imageUrl: \(String(describing: imageUrl))")
                print("- image data size: \(image?.count ?? 0) bytes")
                print("- lang: \(lang)")
                print("- noqueue: \(noqueue)")
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(lang, forKey: .lang)
                try container.encode(noqueue, forKey: .noqueue)
                
                if let imageUrl = imageUrl {
                    try container.encode(imageUrl, forKey: .imageUrl)
                }
                
                if let imageData = image {
                    let base64String = imageData.base64EncodedString()
                    try container.encode(base64String, forKey: .image)
                }
            }
        }
        
        private let request: Request
        
        public init(request: Request) {
            self.request = request
        }
        
        public var queryItems: [URLQueryItem]? {
            var items: [URLQueryItem] = []
            items.append(URLQueryItem(name: "lang", value: request.lang))
            return items
        }
        
        public var body: Data? {
            guard request.image != nil else {
                return nil
            }
            
            print("DEBUG: Preparing JSON request")
            return try? JSONEncoder().encode(request)
        }
    }
}

// MARK: - Factory Methods
public extension SkinAnalysisEndpoints {
    /// Creates a request to analyze a skin image.
    /// - Parameter request: The request object containing image data and parameters
    /// - Returns: An API request configured for skin analysis
    static func analyzeSkin(request: Analyze.Request) -> BMNetwork.APIRequest<Analyze> {
        let endpoint = Analyze(request: request)
        return .init(endpoint: endpoint)
    }
}

#endif
