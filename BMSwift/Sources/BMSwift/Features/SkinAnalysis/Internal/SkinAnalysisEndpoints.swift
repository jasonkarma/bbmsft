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
        
        private let boundary = "---011000010111000001101001"
        
        public var headers: [String: String] {
            var headers = [
                "x-rapidapi-key": "0fc47de525mshb9e37b660469c06p1c82b4jsnc54f0234e207",
                "x-rapidapi-host": "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com",
                "Accept": "application/json"
            ]
            
            // For URL method, set Content-Type to false
            // For image upload, use multipart/form-data
            if request.imageUrl != nil {
                headers["Content-Type"] = "false"
                print("DEBUG: Using URL method with Content-Type: false")
            } else if request.image != nil {
                headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
                print("DEBUG: Using multipart/form-data with boundary: \(boundary)")
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
        }
        
        private let request: Request
        
        public init(request: Request) {
            self.request = request
        }
        
        public var queryItems: [URLQueryItem]? {
            var items: [URLQueryItem] = []
            
            if let url = request.imageUrl {
                items.append(URLQueryItem(name: "imageUrl", value: url))
            }
            
            items.append(URLQueryItem(name: "lang", value: request.lang))
            return items
        }
        
        public var body: Data? {
            // Only use body for direct image upload
            guard let imageData = request.image else {
                return nil
            }
            
            print("DEBUG: Preparing multipart form data request")
            
            var bodyData = Data()
            
            // Add form data part exactly as specified
            let formPart = """
            --\(boundary)\r
            Content-Disposition:form-data; name="image"\r
            \r
            """
            
            if let formData = formPart.data(using: .utf8) {
                bodyData.append(formData)
                print("DEBUG: Form data header (hex):")
                print(formData.map { String(format: "%02x", $0) }.joined())
            }
            
            // Add image data
            bodyData.append(imageData)
            print("DEBUG: Image data size: \(imageData.count) bytes")
            print("DEBUG: First 32 bytes of image data (hex):")
            print(imageData.prefix(32).map { String(format: "%02x", $0) }.joined())
            
            // Add closing boundary
            if let closingBoundary = "\r\n--\(boundary)--".data(using: .utf8) {
                bodyData.append(closingBoundary)
                print("DEBUG: Closing boundary (hex):")
                print(closingBoundary.map { String(format: "%02x", $0) }.joined())
            }
            
            print("DEBUG: Total body size: \(bodyData.count) bytes")
            print("DEBUG: First 100 bytes of complete body (hex):")
            print(bodyData.prefix(100).map { String(format: "%02x", $0) }.joined())
            
            return bodyData
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
