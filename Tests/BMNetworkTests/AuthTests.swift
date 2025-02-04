import XCTest
@testable import BMNetwork

final class AuthTests: XCTestCase {
    var client: BMNetworkV2.NetworkClient!
    var authService: BMNetworkV2.AuthServiceProtocol!
    
    override func setUp() {
        super.setUp()
        client = BMNetworkV2.NetworkClient.shared
        authService = BMNetworkV2.AuthService(client: client)
    }
    
    override func tearDown() {
        client = nil
        authService = nil
        super.tearDown()
    }
    
    func testLoginSuccess() async throws {
        // Given
        let email = "test@example.com"
        let password = "Password123!"
        
        // When
        let response = try await authService.login(email: email, password: password)
        
        // Then
        XCTAssertNotNil(response.token)
        XCTAssertNotNil(response.expiresAt)
    }
    
    func testLoginInvalidCredentials() async {
        // Given
        let email = "invalid@example.com"
        let password = "wrong"
        
        // When/Then
        do {
            _ = try await authService.login(email: email, password: password)
            XCTFail("Expected login to fail")
        } catch let error as BMNetworkV2.APIError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetCurrentSession() async throws {
        // Given
        let email = "test@example.com"
        let password = "Password123!"
        
        // When
        let loginResponse = try await authService.login(email: email, password: password)
        let sessionResponse = try await authService.getCurrentSession()
        
        // Then
        XCTAssertEqual(loginResponse.token, sessionResponse.token)
    }
    
    func testGetCurrentSessionNoToken() async {
        // Given
        BMNetworkV2.TokenManager.shared.clearToken()
        
        // When/Then
        do {
            _ = try await authService.getCurrentSession()
            XCTFail("Expected getCurrentSession to fail")
        } catch let error as BMNetworkV2.APIError {
            XCTAssertEqual(error, .tokenMissing)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
