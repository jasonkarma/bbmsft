import XCTest
@testable import BMNetwork

final class RuntimeChecksTests: XCTestCase {
    // MARK: - Test Doubles
    
    private enum TestFeature {
        static let namespace = "test_feature"
        
        struct TestEndpoint: APIEndpoint {
            typealias RequestType = EmptyRequest
            typealias ResponseType = EmptyResponse
            
            static var featureNamespace: String { namespace }
            var baseURL: URL { URL(string: "https://example.com")! }
            let path: String = "/test"
            let method: HTTPMethod = .get
            let requiresAuth: Bool = true
            let headers: [String: String] = [:]
        }
        
        struct EmptyRequest: Codable {}
        struct EmptyResponse: Codable {}
    }
    
    private enum OtherFeature {
        static let namespace = "other_feature"
    }
    
    // MARK: - Tests
    
    func testValidateAccessSuccess() throws {
        // Given
        let endpoint = TestFeature.TestEndpoint()
        
        // When/Then
        XCTAssertNoThrow(try BMNetworkV2.RuntimeChecks.validateAccess(
            to: endpoint,
            from: TestFeature.namespace
        ))
    }
    
    func testValidateAccessFailure() {
        // Given
        let endpoint = TestFeature.TestEndpoint()
        
        // When/Then
        XCTAssertThrowsError(try BMNetworkV2.RuntimeChecks.validateAccess(
            to: endpoint,
            from: OtherFeature.namespace
        )) { error in
            guard let runtimeError = error as? BMNetworkV2.RuntimeChecks.Error else {
                XCTFail("Expected RuntimeChecks.Error")
                return
            }
            
            switch runtimeError {
            case .crossFeatureAccess(let attempted, let allowed):
                XCTAssertEqual(attempted, TestFeature.namespace)
                XCTAssertEqual(allowed, OtherFeature.namespace)
            default:
                XCTFail("Expected crossFeatureAccess error")
            }
        }
    }
    
    func testValidateAuthSuccess() throws {
        // Given
        let endpoint = TestFeature.TestEndpoint()
        
        // When/Then - Auth required and token present
        XCTAssertNoThrow(try BMNetworkV2.RuntimeChecks.validateAuth(
            for: endpoint,
            hasToken: true
        ))
    }
    
    func testValidateAuthFailure() {
        // Given
        let endpoint = TestFeature.TestEndpoint()
        
        // When/Then - Auth required but no token
        XCTAssertThrowsError(try BMNetworkV2.RuntimeChecks.validateAuth(
            for: endpoint,
            hasToken: false
        )) { error in
            guard let runtimeError = error as? BMNetworkV2.RuntimeChecks.Error else {
                XCTFail("Expected RuntimeChecks.Error")
                return
            }
            
            switch runtimeError {
            case .invalidAuthState(let required, _):
                XCTAssertTrue(required)
            default:
                XCTFail("Expected invalidAuthState error")
            }
        }
    }
}
