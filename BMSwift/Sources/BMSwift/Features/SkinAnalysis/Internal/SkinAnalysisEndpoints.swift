#if canImport(UIKit) && os(iOS)
import Foundation

/// Endpoints for the Skin Analysis feature.
/// Provides endpoints for analyzing skin images using Face++ API's face analysis service.
public enum SkinAnalysisEndpoints {
    
    // MARK: - Endpoint Definitions
    
    /// Endpoint for analyzing skin images.
    /// This endpoint sends image data to Face++ API's face analysis service and receives detailed analysis results.
    public struct Analyze: BMNetwork.APIEndpoint, BMNetwork.RequestBodyEncodable, BMNetwork.RequestBodyValidatable, BMNetwork.HeadersCustomizable {
        // Explicitly declare conformance to RequestBodyEncodable
        public func encodeRequestBody<T: Encodable>(request: T) throws -> Data {
            print("\nDEBUG: === Starting Request Encoding ===\n")
            print("DEBUG: Request type: \(type(of: request))")
            
            guard let typedRequest = request as? Request else {
                print("DEBUG: Error - Invalid request type: \(type(of: request))")
                throw BMNetwork.APIError.encodingError("Invalid request type")
            }
            
            print("DEBUG: Request details:")
            print("- API Key: \(typedRequest.apiKey)")
            print("- API Secret: \(typedRequest.apiSecret)")
            print("- Image URL: \(typedRequest.imageUrl ?? "nil")")
            print("- Image Data: \(typedRequest.image?.count ?? 0) bytes")
            
            let formData = try encodeMultipartFormData(request: typedRequest)
            
            // Debug: Print first 1000 chars of form data
            if let preview = String(data: formData.prefix(1000), encoding: .utf8) {
                print("\nDEBUG: Form Data Preview (first 1000 chars):")
                print(preview)
                print("\nDEBUG: Form Data Size: \(formData.count) bytes")
            }
            
            return formData
        }
        
        public typealias RequestType = Request
        public typealias ResponseType = SkinAnalysisModels.Response
        

        // MARK: - Endpoint Configuration
        
        // Override default base URL to use Face++ API
        public var baseURL: URL? { URL(string: "https://api-cn.faceplusplus.com") }
        public let path: String = "/facepp/v3/detect"
        public let method: BMNetwork.HTTPMethod = .post
        public var requiresAuth: Bool { false }
        public var timeoutInterval: TimeInterval? { 60 }
        public var cachePolicy: URLRequest.CachePolicy? { .reloadIgnoringLocalAndRemoteCacheData }
        
        private let boundary = "Boundary-\(UUID().uuidString)"
        
        public var headers: [String: String] {
            ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        }
        
        // MARK: - Request Body Validation
        
        public func validateRequestBody(_ body: Data, headers: [String: String]) throws {
            // Verify Content-Type header exists and has boundary
            guard let contentType = headers["Content-Type"],
                  contentType.hasPrefix("multipart/form-data"),
                  let boundary = contentType.components(separatedBy: "boundary=").last?.trimmingCharacters(in: .whitespaces) else {
                throw BMNetwork.APIError.encodingError("Invalid Content-Type header for multipart form data")
            }
            
            // Verify boundary exists in body
            guard let bodyString = String(data: body.prefix(1000), encoding: .utf8),
                  bodyString.contains(boundary.trimmingCharacters(in: CharacterSet(charactersIn: "-"))) else {
                throw BMNetwork.APIError.encodingError("Boundary not found in request body")
            }
            
            // Verify required fields
            let requiredFields = ["api_key", "api_secret"]
            for field in requiredFields {
                if !bodyString.contains("name=\"\(field)\"") {
                    throw BMNetwork.APIError.encodingError("Missing required field: \(field)")
                }
            }
        }
        
        // MARK: - Headers Customization
        
        public func customizeHeaders(for body: Data) -> [String: String] {
            [:] // Headers are already set in the endpoint configuration
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
            print("DEBUG: Initialized SkinAnalysisEndpoints.Analyze with request")
        }
        
        public var queryItems: [URLQueryItem]? { nil }
        
        public func encode(to encoder: Encoder) throws {}
        
        private func encodeMultipartFormData(request: Request) throws -> Data {
            var formData = Data()
            
            print("\nDEBUG: === Building Multipart Form Data ===\n")
            print("DEBUG: Boundary: \(boundary)")
            
            // Add required fields first
            print("\nDEBUG: Adding API credentials:")
            addFormField(name: "api_key", value: request.apiKey, to: &formData)
            addFormField(name: "api_secret", value: request.apiSecret, to: &formData)
            
            // Add final boundary
            let finalBoundary = "--\(boundary)--\r\n"
            formData.append(finalBoundary.data(using: .utf8)!)
            
            // Debug: Print the entire form data as string
            if let formDataString = String(data: formData, encoding: .utf8) {
                print("\nDEBUG: Complete Form Data:\n\(formDataString)\n")
            }
            
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
            formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            print("DEBUG: Final form data size: \(formData.count) bytes")
            
            // Verify the form data contains the boundary
            if let formString = String(data: formData.prefix(1000), encoding: .utf8) {
                print("DEBUG: First 1000 chars of form data:\n\(formString)")
            }
            
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
            print("\nDEBUG: Adding field: \(name)")
            
            let boundaryLine = "--\(boundary)\r\n"
            let headerLine = "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
            let valueLine = "\(value)\r\n"
            
            print("DEBUG: Field components:")
            print("1. Boundary: \(boundaryLine)")
            print("2. Header: \(headerLine)")
            print("3. Value: \(valueLine)")
            
            let fieldData = boundaryLine.data(using: .utf8)! +
                           headerLine.data(using: .utf8)! +
                           valueLine.data(using: .utf8)!
            
            data.append(fieldData)
            
            print("DEBUG: Field added successfully")
            print("DEBUG: Field data (decoded):\n\(String(data: fieldData, encoding: .utf8) ?? "<failed to decode>")")
        }
        
        private func addFileField(name: String, filename: String, data fileData: Data, to data: inout Data) {
            print("\nDEBUG: === Adding File Field ===\n")
            print("DEBUG: Field name: \(name)")
            print("DEBUG: Filename: \(filename)")
            print("DEBUG: File size: \(fileData.count) bytes")
            
            let boundaryLine = "--\(boundary)\r\n"
            let headerLine = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
            let contentTypeLine = "Content-Type: image/jpeg\r\n\r\n"
            
            print("\nDEBUG: File field components:")
            print("1. Boundary: \(boundaryLine)")
            print("2. Header: \(headerLine)")
            print("3. Content-Type: \(contentTypeLine)")
            
            data.append(boundaryLine.data(using: .utf8)!)
            data.append(headerLine.data(using: .utf8)!)
            data.append(contentTypeLine.data(using: .utf8)!)
            data.append(fileData)
            data.append("\r\n".data(using: .utf8)!)
            
            print("DEBUG: File field added successfully")
            
            // Verify field was added
            if let preview = String(data: data.suffix(200), encoding: .utf8) {
                print("DEBUG: Last 200 chars after adding file:\n\(preview)")
            }
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
