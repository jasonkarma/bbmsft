import Foundation

// MARK: - API Models
public struct APIResponse<T: Codable>: Codable {
    public let data: T?
    public let error: String?
}

public struct LoginRequest: Codable {
    public let email: String
    public let password: String
}

public struct LoginResponse: Codable {
    public let token: String
    public let expiredAt: String
    public let firstLogin: Bool
    
    private enum CodingKeys: String, CodingKey {
        case token
        case expiredAt = "expires_at"
        case firstLogin = "first_login"
    }
}

public struct RegisterRequest: Codable {
    public let email: String
    public let password: String
    public let confirmPassword: String
    
    private enum CodingKeys: String, CodingKey {
        case email
        case password
        case confirmPassword = "confirm_password"
    }
}

public struct RegisterResponse: Codable {
    public let message: String
}

public struct ForgotPasswordRequest: Codable {
    public let email: String
}

public struct ForgotPasswordResponse: Codable {
    public let message: String
}

public struct ErrorResponse: Codable {
    public let error: String
}

// MARK: - Network Error
public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case customError(String)
    case decodingError
    case invalidCredentials(message: String)
    case unauthorized
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無效的URL"
        case .invalidResponse:
            return "無效的回應"
        case .serverError(let code):
            return "伺服器錯誤 (\(code))"
        case .customError(let message):
            return message
        case .decodingError:
            return "資料解析錯誤"
        case .invalidCredentials(let message):
            return message
        case .unauthorized:
            return "請重新登入"
        }
    }
}

// MARK: - API Service
public class APIService {
    private let baseURL = "https://wiki.kinglyrobot.com/api"
    public static let shared = APIService()
    
    private init() {}
    
    private func makeRequest<T: Codable>(_ endpoint: String,
                                       method: String = "POST",
                                       body: Codable? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                print("Request body: \(String(data: jsonData, encoding: .utf8) ?? "")")  // Debug print
                request.httpBody = jsonData
            } catch {
                print("Encoding error: \(error)")  // Debug print
                throw APIError.decodingError
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Debug print
        print("Response status code: \(httpResponse.statusCode)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")  // Debug print
                throw APIError.decodingError
            }
        case 401:
            throw APIError.unauthorized
        case 404:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.customError(errorResponse.error)
            } catch {
                print("Error response decoding error: \(error)")  // Debug print
                throw APIError.customError("未知錯誤")
            }
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Auth API
extension APIService {
    public func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw APIError.invalidURL
        }
        
        let request = LoginRequest(email: email, password: password)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            print("Request body: \(String(data: jsonData, encoding: .utf8) ?? "")")  // Debug print
            urlRequest.httpBody = jsonData
        } catch {
            print("Encoding error: \(error)")  // Debug print
            throw APIError.decodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Debug print
        print("Response status code: \(httpResponse.statusCode)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(LoginResponse.self, from: data)
            } catch {
                print("Decoding error: \(error)")  // Debug print
                throw APIError.decodingError
            }
        case 404:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.invalidCredentials(message: errorResponse.error)
            } catch {
                print("Error response decoding error: \(error)")  // Debug print
                throw APIError.invalidCredentials(message: "帳號/密碼輸入錯誤。")
            }
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    public func register(email: String, password: String, confirmPassword: String) async throws -> RegisterResponse {
        let request = RegisterRequest(email: email, password: password, confirmPassword: confirmPassword)
        return try await makeRequest("/register", body: request)
    }
    
    public func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        let request = ForgotPasswordRequest(email: email)
        return try await makeRequest("/password/email", body: request)
    }
    
    public func logout() {
        // Clear any stored tokens or user data
        // Add token clearing logic here if needed
    }
}
