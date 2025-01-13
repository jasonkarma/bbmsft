import Foundation

public class SkinAnalyzeAPIService: APIService {
    public static let shared = SkinAnalyzeAPIService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Skin Analysis Endpoints
    private enum SkinAnalyzeEndpoint {
        static let analyze = "/skin/analyze"
        static let results = "/skin/results"
    }
    
    // MARK: - Skin Analysis Methods
    public func uploadImage(imageData: Data, token: String) async throws -> String {
        let url = URL(string: "\(baseURL)\(SkinAnalyzeEndpoint.analyze)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
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
    
    public func getAnalysisResults(token: String) async throws -> [String: Any] {
        let url = URL(string: "\(baseURL)\(SkinAnalyzeEndpoint.results)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
}
