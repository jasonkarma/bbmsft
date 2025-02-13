#if canImport(UIKit) && os(iOS)
import Foundation

/// Endpoints for the Skin Analysis feature.
/// Provides endpoints for analyzing skin images using Face++ API's face analysis service.
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Endpoint for analyzing skin images.
    /// This endpoint sends image data to Face++ API's face analysis service and receives detailed analysis results.
    public struct Analyze: BMNetwork.APIEndpoint, BMNetwork.RequestBodyEncodable {
        public typealias RequestType = Request
        public typealias ResponseType = SkinAnalysisModels.Response
        
        public let path: String = "/facepp/v3/detect"
        public let method: BMNetwork.HTTPMethod = .post
        
        public var baseURL: URL? { URL(string: "https://api-cn.faceplusplus.com") }
        
        private let boundary = "Boundary-\(UUID().uuidString)"
        
        public var headers: [String: String] {
            ["Content-Type": "application/x-www-form-urlencoded"]
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
        }
        
        private let request: Request
        
        public init(request: Request) {
            self.request = request
        }
        
        public var queryItems: [URLQueryItem]? { nil }
        
        public func encode(to encoder: Encoder) throws {}
        
        public func encodeRequestBody<T: Encodable>(request: T) throws -> Data {
            guard let request = request as? Request else {
                throw BMNetwork.APIError.encodingError("Invalid request type")
            }
            
            var params: [String: String] = [
                "api_key": request.apiKey,
                "api_secret": request.apiSecret,
                "return_attributes": request.returnAttributes
            ]
            
            if let imageUrl = request.imageUrl {
                params["image_url"] = imageUrl
            }
            
            if let imageData = request.image {
                params["image_base64"] = imageData.base64EncodedString()
            }
            
            let pairs = params.map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            
            return pairs.joined(separator: "&").data(using: .utf8) ?? Data()
        }
        private func addFormField(name: String, value: String, to data: inout Data) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        private func addFileField(name: String, filename: String, data fileData: Data, to data: inout Data) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(fileData)
            data.append("\r\n".data(using: .utf8)!)
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
