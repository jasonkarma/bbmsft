import XCTest
@testable import BMNetwork

final class AuthenticationTests: XCTestCase {
    // MARK: - Test Doubles
    
    private class MockAuthHandler: AuthenticationHandler {
        var getTokenCallCount = 0
        var handleErrorCallCount = 0
        var clearAuthCallCount = 0
        var shouldRetryOnError = false
        var mockToken: String?
        var error: Error?
        
        func getToken() async throws -> String? {
            getTokenCallCount += 1
            if let error = error {
                throw error
            }
            return mockToken
        }
        
        func handleAuthenticationError(_ error: Error) async -> Bool {
            handleErrorCallCount += 1
            return shouldRetryOnError
        }
        
        func clearAuthentication() {
            clearAuthCallCount += 1
        }
    }
    
    private struct MockEndpoint: APIEndpoint {
        typealias RequestType = EmptyRequest
        typealias ResponseType = MockResponse
        
        let baseURL = URL(string: "https://example.com")!
        let path: String
        let method: HTTPMethod
        let requiresAuth: Bool
        
        init(path: String = "/test",
             method: HTTPMethod = .get,
             requiresAuth: Bool = true) {
            self.path = path
            self.method = method
            self.requiresAuth = requiresAuth
        }
    }
    
    private struct MockResponse: Codable {
        let value: String
    }
    
    // MARK: - Tests
    
    func testAuthenticatedRequestSuccess() async throws {
        // Given
        let mockHandler = MockAuthHandler()
        mockHandler.mockToken = "test_token"
        
        let config = BMNetworkV2.Configuration()
        let client = BMNetworkV2.NetworkClient(
            configuration: config,
            authHandler: mockHandler
        )
        
        let endpoint = MockEndpoint()
        
        // When/Then
        // This will throw if the request fails
        _ = try await client.send(endpoint)
        
        // Verify
        XCTAssertEqual(mockHandler.getTokenCallCount, 1)
        XCTAssertEqual(mockHandler.handleErrorCallCount, 0)
    }
    
    func testUnauthenticatedRequest() async throws {
        // Given
        let mockHandler = MockAuthHandler()
        let config = BMNetworkV2.Configuration()
        let client = BMNetworkV2.NetworkClient(
            configuration: config,
            authHandler: mockHandler
        )
        
        let endpoint = MockEndpoint(requiresAuth: false)
        
        // When
        _ = try await client.send(endpoint)
        
        // Then
        XCTAssertEqual(mockHandler.getTokenCallCount, 0)
        XCTAssertEqual(mockHandler.handleErrorCallCount, 0)
    }
    
    func testAuthenticationRetry() async throws {
        // Given
        let mockHandler = MockAuthHandler()
        mockHandler.mockToken = "test_token"
        mockHandler.shouldRetryOnError = true
        
        let config = BMNetworkV2.Configuration(
            responseInterceptors: [
                // Add interceptor that will throw unauthorized on first try
                TestResponseInterceptor(
                    shouldThrowUnauthorized: true,
                    throwCount: 1
                )
            ]
        )
        
        let client = BMNetworkV2.NetworkClient(
            configuration: config,
            authHandler: mockHandler
        )
        
        let endpoint = MockEndpoint()
        
        // When
        _ = try await client.send(endpoint)
        
        // Then
        XCTAssertEqual(mockHandler.getTokenCallCount, 2) // Initial + retry
        XCTAssertEqual(mockHandler.handleErrorCallCount, 1)
    }
    
    func testAuthenticationRetryLimit() async {
        // Given
        let mockHandler = MockAuthHandler()
        mockHandler.mockToken = "test_token"
        mockHandler.shouldRetryOnError = true
        
        let config = BMNetworkV2.Configuration(
            responseInterceptors: [
                // Add interceptor that will always throw unauthorized
                TestResponseInterceptor(
                    shouldThrowUnauthorized: true,
                    throwCount: .max
                )
            ]
        )
        
        let client = BMNetworkV2.NetworkClient(
            configuration: config,
            authHandler: mockHandler
        )
        
        let endpoint = MockEndpoint()
        
        // When/Then
        do {
            _ = try await client.send(endpoint)
            XCTFail("Expected error")
        } catch let error as BMNetworkV2.APIError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Verify retry was attempted but limited
        XCTAssertEqual(mockHandler.getTokenCallCount, 2) // Initial + 1 retry
        XCTAssertEqual(mockHandler.handleErrorCallCount, 1)
    }
}

// MARK: - Test Helpers

private struct TestResponseInterceptor: ResponseInterceptor {
    let shouldThrowUnauthorized: Bool
    let throwCount: Int
    private var currentCount = 0
    
    func intercept(_ response: URLResponse, data: Data) async throws -> Data {
        if shouldThrowUnauthorized && currentCount < throwCount {
            currentCount += 1
            throw BMNetworkV2.APIError.unauthorized
        }
        return data
    }
}
