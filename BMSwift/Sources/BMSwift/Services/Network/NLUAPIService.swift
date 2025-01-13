import Foundation

public class NLUAPIService: APIService {
    public static let shared = NLUAPIService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - NLU Endpoints
    private enum NLUEndpoint {
        static let analyzeText = "/nlu/analyzeText"
        static let getResponse = "/nlu/getResponse"
    }
    
    // MARK: - NLU Methods
    public func analyzeText(text: String, token: String) async throws -> [String: Any] {
        let url = URL(string: "\(baseURL)\(NLUEndpoint.analyzeText)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let result = json as? [String: Any] else {
                    throw APIError.decodingError
                }
                return result
            } catch {
                throw APIError.decodingError
            }
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    public func getResponse(for text: String, token: String) async throws -> String {
        let url = URL(string: "\(baseURL)\(NLUEndpoint.getResponse)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            guard let result = String(data: data, encoding: .utf8) else {
                throw APIError.decodingError
            }
            return result
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}
