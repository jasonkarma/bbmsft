#if canImport(Foundation)
import Foundation

public protocol FacePlusPlusService {
    func detectFaces(request: FacePlusPlusDetectRequest) async throws -> FacePlusPlusDetectResponse
}

public final class FacePlusPlusServiceImpl: FacePlusPlusService {
    private let baseURL = "https://api-cn.faceplusplus.com/facepp/v3/detect"
    
    public init() {}
    
    public func detectFaces(request: FacePlusPlusDetectRequest) async throws -> FacePlusPlusDetectResponse {
        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var bodyData = Data()
        
        // Add API key and secret
        bodyData.append(createFormField(named: "api_key", value: request.apiKey, boundary: boundary))
        bodyData.append(createFormField(named: "api_secret", value: request.apiSecret, boundary: boundary))
        
        // Add optional parameters
        if let returnLandmark = request.returnLandmark {
            bodyData.append(createFormField(named: "return_landmark", value: String(returnLandmark), boundary: boundary))
        }
        
        if let returnAttributes = request.returnAttributes {
            bodyData.append(createFormField(named: "return_attributes", value: returnAttributes, boundary: boundary))
        }
        
        // Add image data (only one of these should be non-nil)
        if let imageData = request.imageData {
            bodyData.append(createFileField(named: "image_file", filename: "image.jpg", data: imageData, boundary: boundary))
        } else if let imageURL = request.imageURL {
            bodyData.append(createFormField(named: "image_url", value: imageURL, boundary: boundary))
        } else if let imageBase64 = request.imageBase64 {
            bodyData.append(createFormField(named: "image_base64", value: imageBase64, boundary: boundary))
        }
        
        // Add closing boundary
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = bodyData
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Check if we got an error response
        if httpResponse.statusCode != 200 {
            let errorResponse = try JSONDecoder().decode(FacePlusPlusError.self, from: data)
            throw FacePlusPlusServiceError.apiError(errorResponse)
        }
        
        return try JSONDecoder().decode(FacePlusPlusDetectResponse.self, from: data)
    }
    
    private func createFormField(named name: String, value: String, boundary: String) -> Data {
        var fieldData = Data()
        fieldData.append("--\(boundary)\r\n".data(using: .utf8)!)
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        fieldData.append("\(value)\r\n".data(using: .utf8)!)
        return fieldData
    }
    
    private func createFileField(named name: String, filename: String, data: Data, boundary: String) -> Data {
        var fieldData = Data()
        fieldData.append("--\(boundary)\r\n".data(using: .utf8)!)
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        fieldData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        fieldData.append(data)
        fieldData.append("\r\n".data(using: .utf8)!)
        return fieldData
    }
}

public enum FacePlusPlusServiceError: LocalizedError {
    case apiError(FacePlusPlusError)
    
    public var errorDescription: String? {
        switch self {
        case .apiError(let error):
            return "Face++ API Error: \(error.errorMessage)"
        }
    }
}
#endif
