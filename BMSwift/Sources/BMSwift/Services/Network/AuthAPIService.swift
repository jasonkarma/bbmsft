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
    public let from: String
    public let username: String
    public let email: String
    public let password: String
    
    private enum CodingKeys: String, CodingKey {
        case from
        case username
        case email
        case password
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
    public let error: [String: [String]]
    
    public var localizedDescription: String {
        let messages = error.values.flatMap { $0 }
        return messages.joined(separator: "\n")
    }
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

// MARK: - Auth API Service
public class AuthAPIService {
    private let baseURL = "https://wiki.kinglyrobot.com/api"
    public static let shared = AuthAPIService()
    
    private init() {}
    
    // MARK: - Authentication Endpoints
    private enum AuthEndpoint {
        static let login = "/login"
        static let register = "/register"
        static let forgotPassword = "/forgot-password"
    }
    
    // MARK: - Authentication Methods
    public func login(email: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(email: email, password: password)
        return try await makeRequest(AuthEndpoint.login, body: body)
    }
    
    public func register(username: String, email: String, password: String) async throws -> RegisterResponse {
        let body = RegisterRequest(
            from: "beauty_app",
            username: username,
            email: email,
            password: password
        )
        return try await makeRequest(AuthEndpoint.register, body: body)
    }
    
    public func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        let request = ForgotPasswordRequest(email: email)
        return try await makeRequest("/password/email", body: request)
    }
    
    public func logout() {
        // Clear any stored tokens or user data
        // Add token clearing logic here if needed
    }
    
    private func makeRequest<T: Codable>(_ endpoint: String,
                                       method: String = "POST",
                                       body: Codable? = nil,
                                       token: String? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        print("Request URL: \(url.absoluteString)")  // Debug URL
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
        case 200, 201:  // Handle both 200 and 201 as success
            do {
                // First check if there's an error message in the response
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorDict["error"] as? String {
                    throw APIError.customError(errorMessage)
                }
                
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")  // Debug print
                if let apiError = error as? APIError {
                    throw apiError
                }
                throw APIError.decodingError
            }
        case 401:
            throw APIError.unauthorized
        case 422:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                if let emailErrors = errorResponse.error["email"] {
                    let decodedErrors = emailErrors.compactMap { error -> String? in
                        guard let data = error.data(using: .utf8) else { return nil }
                        return String(data: data, encoding: .utf8)
                    }
                    throw APIError.customError(decodedErrors.joined(separator: "\n"))
                }
                if let _ = errorResponse.error["username"] {
                    throw APIError.customError("此用戶暱稱已被使用")
                }
                throw APIError.customError("註冊失敗")
            } catch {
                if let apiError = error as? APIError {
                    throw apiError
                }
                throw APIError.customError("註冊失敗")
            }
        case 404:
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.customError(errorResponse.localizedDescription)
            } catch {
                print("Error response decoding error: \(error)")  // Debug print
                throw APIError.customError("未知錯誤")
            }
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}
