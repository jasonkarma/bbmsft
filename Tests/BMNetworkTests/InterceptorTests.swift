import XCTest
@testable import BMNetwork

final class InterceptorTests: XCTestCase {
    // MARK: - Auth Request Interceptor Tests
    
    func testAuthRequestInterceptorWithToken() async throws {
        // Given
        let tokenManager = BMNetworkV2.TokenManager.shared
        let token = "test_token"
        try tokenManager.saveToken(token)
        let interceptor = BMNetworkV2.AuthRequestInterceptor(tokenManager: tokenManager)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When
        let modifiedRequest = try await interceptor.intercept(request)
        
        // Then
        XCTAssertEqual(
            modifiedRequest.value(forHTTPHeaderField: "Authorization"),
            "Bearer \(token)"
        )
        
        // Cleanup
        tokenManager.clearToken()
    }
    
    func testAuthRequestInterceptorWithoutToken() async throws {
        // Given
        let tokenManager = BMNetworkV2.TokenManager.shared
        tokenManager.clearToken()
        let interceptor = BMNetworkV2.AuthRequestInterceptor(tokenManager: tokenManager)
        
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When
        let modifiedRequest = try await interceptor.intercept(request)
        
        // Then
        XCTAssertNil(modifiedRequest.value(forHTTPHeaderField: "Authorization"))
    }
    
    // MARK: - Error Response Interceptor Tests
    
    func testErrorResponseInterceptorSuccess() async throws {
        // Given
        let interceptor = BMNetworkV2.ErrorResponseInterceptor()
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = Data("{\"key\":\"value\"}".utf8)
        
        // When
        let processedData = try await interceptor.intercept(response, data: data)
        
        // Then
        XCTAssertEqual(processedData, data)
    }
    
    func testErrorResponseInterceptorUnauthorized() async {
        // Given
        let interceptor = BMNetworkV2.ErrorResponseInterceptor()
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = Data()
        
        // When/Then
        do {
            _ = try await interceptor.intercept(response, data: data)
            XCTFail("Expected unauthorized error")
        } catch let error as BMNetworkV2.APIError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testErrorResponseInterceptorServerError() async {
        // Given
        let interceptor = BMNetworkV2.ErrorResponseInterceptor()
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        let errorMessage = "Internal server error"
        let data = Data("{\"message\":\"\(errorMessage)\"}".utf8)
        
        // When/Then
        do {
            _ = try await interceptor.intercept(response, data: data)
            XCTFail("Expected server error")
        } catch let error as BMNetworkV2.APIError {
            if case .serverError(let message) = error {
                XCTAssertEqual(message, errorMessage)
            } else {
                XCTFail("Expected server error with message")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
