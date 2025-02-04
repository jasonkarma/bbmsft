import XCTest
@testable import BMNetwork

final class NetworkClientConfigurationTests: XCTestCase {
    func testDefaultConfiguration() {
        // Given/When
        let config = BMNetworkV2.Configuration.default
        
        // Then
        XCTAssertEqual(config.requestInterceptors.count, 1)
        XCTAssertEqual(config.responseInterceptors.count, 1)
        XCTAssert(config.requestInterceptors[0] is BMNetworkV2.AuthRequestInterceptor)
        XCTAssert(config.responseInterceptors[0] is BMNetworkV2.ErrorResponseInterceptor)
    }
    
    func testCustomConfiguration() {
        // Given
        let customHeaders = ["Custom-Header": "Value"]
        let sessionConfig = URLSessionConfiguration.ephemeral
        let customInterceptors = [BMNetworkV2.AuthRequestInterceptor()]
        let customResponseInterceptors = [BMNetworkV2.ErrorResponseInterceptor()]
        
        // When
        let config = BMNetworkV2.Configuration(
            defaultHeaders: customHeaders,
            sessionConfiguration: sessionConfig,
            requestInterceptors: customInterceptors,
            responseInterceptors: customResponseInterceptors
        )
        
        // Then
        XCTAssertEqual(config.defaultHeaders, customHeaders)
        XCTAssertEqual(config.sessionConfiguration, sessionConfig)
        XCTAssertEqual(config.requestInterceptors.count, customInterceptors.count)
        XCTAssertEqual(config.responseInterceptors.count, customResponseInterceptors.count)
    }
    
    func testNetworkClientWithConfiguration() {
        // Given
        let config = BMNetworkV2.Configuration.development
        
        // When
        let client = BMNetworkV2.NetworkClient(configuration: config)
        
        // Then
        XCTAssertNotNil(client)
    }
    
    func testSharedInstance() {
        // Given/When
        let client = BMNetworkV2.NetworkClient.shared
        
        // Then
        XCTAssertNotNil(client)
    }
}
