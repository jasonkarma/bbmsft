#if canImport(UIKit) && os(iOS)
import Foundation

/// Endpoints for the Skin Analysis feature.
/// Provides endpoints for analyzing skin images using Face++ API's face analysis service.
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Endpoint for analyzing skin images.
    /// This endpoint sends image data to Face++ API's face analysis service and receives detailed analysis results.
    public struct Analyze: BMNetwork.APIEndpoint {
        public typealias RequestType = Request
        public typealias ResponseType = SkinAnalysisModels.Response
        
        public let path: String = "/facepp/v3/detect"
        public let method: BMNetwork.HTTPMethod = .post
        
        public var baseURL: URL? { URL(string: "https://api-cn.faceplusplus.com") }
        
        public var headers: [String: String] {
            var headers: [String: String] = [:]
            
            // Only set Content-Type if we're sending form data
            if request.image != nil {
                let boundary = "Boundary-\(UUID().uuidString)"
                headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            }
            
            return headers
        }
        
        public struct Request: Encodable {
            let imageUrl: String?
            let image: Data?
            let apiKey: String = "vUphvqXtMmQJXKT91o9U1pvBoGd8RBv9"
            let apiSecret: String = "BsyR4U3VOqH5jLDbRaXX4KyPVzTp1rGO"
            let returnAttributes: String = "gender,age,glass,headpose,smile,blur,eyestatus,emotion,facequality,beauty,mouthstatus,eyegaze,skinstatus"
            
            public init(imageUrl: String? = nil, image: Data? = nil) {
                self.imageUrl = imageUrl
                self.image = image
                
                print("DEBUG: Request initialized with:")
                print("- imageUrl: \(String(describing: imageUrl))")
                print("- image data size: \(image?.count ?? 0) bytes")
            }
            
            public func encode(to encoder: Encoder) throws {
                // This will be handled by queryItems and body
            }
        }
        
        private let request: Request
        
        public init(request: Request) {
            self.request = request
        }
        
        public var queryItems: [URLQueryItem]? {
            var items = [
                URLQueryItem(name: "api_key", value: request.apiKey),
                URLQueryItem(name: "api_secret", value: request.apiSecret),
                URLQueryItem(name: "return_attributes", value: request.returnAttributes)
            ]
            
            if let imageUrl = request.imageUrl {
                items.append(URLQueryItem(name: "image_url", value: imageUrl))
            }
            
            return items
        }
        
        public var body: Data? {
            guard let imageData = request.image else { return nil }
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var bodyData = Data()
            
            // Add image data
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"image_file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
            
            // Add closing boundary
            bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
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
