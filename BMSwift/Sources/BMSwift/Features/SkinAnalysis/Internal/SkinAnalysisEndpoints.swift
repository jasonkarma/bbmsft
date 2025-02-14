#if canImport(UIKit) && os(iOS)
import Foundation

/// Endpoints for the Skin Analysis feature.
/// Provides endpoints for analyzing skin images using Face++ API's face analysis service.
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Endpoint for analyzing skin images.
    /// This endpoint sends image data to Face++ API's face analysis service and receives detailed analysis results.
    public struct Analyze: BMNetwork.APIEndpoint, BMNetwork.RequestBodyEncodable {
        // Explicitly declare conformance to RequestBodyEncodable
        public func encodeRequestBody<T>(request: T) throws -> Data where T : Encodable {
            print("DEBUG: encodeRequestBody called with type: \(type(of: request))")
            guard let request = request as? Request else {
                print("DEBUG: Error - Invalid request type: \(type(of: request))")
                throw BMNetwork.APIError.encodingError("Invalid request type")
            }
            return try encodeMultipartFormData(request: request)
        }
        
        public typealias RequestType = Request
        public typealias ResponseType = SkinAnalysisModels.Response
        

        // Override default base URL to use Face++ API
        public var baseURL: URL? { URL(string: "https://api-cn.faceplusplus.com") }
        public let path: String = "/facepp/v3/detect"
        public let method: BMNetwork.HTTPMethod = .post
        public var requiresAuth: Bool { false }
        public var timeoutInterval: TimeInterval? { 60 }
        public var cachePolicy: URLRequest.CachePolicy? { .reloadIgnoringLocalAndRemoteCacheData }
        
        private let boundary = "--Boundary-\(UUID().uuidString)"
        
        public var headers: [String: String] {
            let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
            print("DEBUG: Setting request headers: \(headers)")
            return headers
        }
        

        
        public struct Request: Encodable {
            let imageUrl: String?
            let image: Data?
            let useImageFile: Bool
            let apiKey: String = "C95V2wN_jJKggUbDD6r6pYGPDCVlvewW"
            let apiSecret: String = "YnPlIpwAoI2M1u2nez2Ysrn6doSewIgC"
            let returnLandmark: Int = 2  // Return 106 facial landmark points
            let returnAttributes: String = "gender,age,smiling,headpose,facequality,blur,eyestatus,emotion,beauty,mouthstatus,eyegaze,skinstatus"
            
            public init(imageUrl: String) {
                self.imageUrl = imageUrl
                self.image = nil
                self.useImageFile = false
                
                print("DEBUG: Request initialized with:")
                print("- imageUrl: \(imageUrl)")
                print("- image data size: 0 bytes")
                print("- using image_file: false")
            }
            
            public init(image: Data) {
                self.imageUrl = nil
                self.image = image
                self.useImageFile = true
                
                print("DEBUG: Request initialized with:")
                print("- imageUrl: nil")
                print("- image data size: \(image.count) bytes")
                print("- using image_file: true")
            }
        }
        
        private let request: Request
        
        public init(request: Request) {
            self.request = request
        }
        
        public var queryItems: [URLQueryItem]? { nil }
        
        public func encode(to encoder: Encoder) throws {}
        
        private func encodeMultipartFormData(request: Request) throws -> Data {
            guard let request = request as? Request else {
                throw BMNetwork.APIError.encodingError("Invalid request type")
            }
            
            var formData = Data()
            
            print("DEBUG: Starting form data construction")
            print("DEBUG: Using boundary: \(boundary)")
            
            // Add required fields first
            addFormField(name: "api_key", value: request.apiKey, to: &formData)
            addFormField(name: "api_secret", value: request.apiSecret, to: &formData)
            
            print("DEBUG: Added authentication fields:")
            print("- api_key: \(request.apiKey)")
            print("- api_secret: \(request.apiSecret)")
            
            // Add image data
            if let imageUrl = request.imageUrl {
                print("DEBUG: Adding image URL: \(imageUrl)")
                addFormField(name: "image_url", value: imageUrl, to: &formData)
            } else if let imageData = request.image {
                print("DEBUG: Adding image file data (\(imageData.count) bytes)")
                addFileField(name: "image_file", filename: "image.jpg", data: imageData, to: &formData)
            } else {
                print("DEBUG: Error - No image data provided")
                throw BMNetwork.APIError.encodingError("No image data provided")
            }
            
            // Add optional fields
            print("DEBUG: Adding optional fields:")
            print("- return_landmark: \(request.returnLandmark)")
            print("- return_attributes: \(request.returnAttributes)")
            
            addFormField(name: "return_landmark", value: String(request.returnLandmark), to: &formData)
            addFormField(name: "return_attributes", value: request.returnAttributes, to: &formData)
            
            // Add final boundary
            formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            print("DEBUG: Final form data size: \(formData.count) bytes")
            
            return formData
        }
        
        private func encodeURLForm(params: [String: String]) -> Data {
            let pairs = params.map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            
            return pairs.joined(separator: "&").data(using: .utf8) ?? Data()
        }
        private func addFormField(name: String, value: String, to data: inout Data) {
            print("DEBUG: Adding form field: \(name)")
            // Add boundary
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            // Add field header
            let header = "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
            data.append(header.data(using: .utf8)!)
            // Add field value
            data.append("\(value)\r\n".data(using: .utf8)!)
            print("DEBUG: Added field value: \(value)")
        }
        
        private func addFileField(name: String, filename: String, data fileData: Data, to data: inout Data) {
            print("DEBUG: Adding file field: \(name), filename: \(filename)")
            // Add boundary
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            // Add file header
            let header = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
            data.append(header.data(using: .utf8)!)
            data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            // Add file data
            data.append(fileData)
            data.append("\r\n".data(using: .utf8)!)
            print("DEBUG: Added file data (\(fileData.count) bytes)")
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
