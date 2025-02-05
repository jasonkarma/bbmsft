#if canImport(UIKit) && os(iOS)
import XCTest
@testable import BMSwift
import UIKit

final class SkinAnalysisTests: XCTestCase {
    private var service: SkinAnalysisServiceImpl!
    private var mockClient: MockNetworkClient!
    private var mockImageUploader: MockImageUploader!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
        mockImageUploader = MockImageUploader()
        service = SkinAnalysisServiceImpl(
            client: BMNetwork.NetworkClient(configuration: .init(baseURL: URL(string: "https://test.example.com")!)),
            imageUploader: mockImageUploader
        )
    }
    
    func testSuccessfulAnalysis() async throws {
        // Given
        let mockImage = UIImage()
        let mockImgurResponse = BMNetwork.ImgurResponse(
            data: .init(id: "test123", title: nil, description: nil, type: "image/jpeg", link: "https://example.com/test.jpg"),
            success: true,
            status: 200
        )
        mockImageUploader.setMockResponse(mockImgurResponse)
        
        let mockAnalysisResponse = RapidAPI.Response(
            result: .init(
                photoAnalysis: .init(
                    composition: .init(description: "Good", notableElements: ["test"], compositionScore: 80),
                    lighting: .init(description: "Good", notableElements: ["test"], lightingScore: 85),
                    color: .init(palette: "Warm", notableElements: ["test"], colorScore: 90),
                    technicalQuality: .init(sharpness: "Good", exposure: "Good", depthOfField: "Good", qualityScore: 88),
                    facialFeatures: .init(
                        overallStructure: .init(description: "Good", score: 85),
                        skinQuality: .init(description: "Good", score: 87),
                        eyeArea: .init(description: "Good", score: 86),
                        mouthArea: .init(description: "Good", score: 84),
                        noseArea: .init(description: "Good", score: 83),
                        cheekArea: .init(description: "Good", score: 85),
                        jawArea: .init(description: "Good", score: 82)
                    )
                ),
                overallImpression: .init(
                    mood: "Natural",
                    uniqueElements: ["test"],
                    overallScore: 85,
                    suggestions: ["Suggestion 1", "Suggestion 2"]
                )
            ),
            status: "success",
            message: "Success",
            time: 123456,
            cacheTime: 123456
        )
        mockClient.setMockResponse(mockAnalysisResponse)
        
        // When
        let result = try await service.analyzeSkin(image: mockImage)
        
        // Then
        XCTAssertEqual(result.overallScore, 85)
        XCTAssertEqual(result.detailedScores.count, 6)
        XCTAssertEqual(result.recommendations.count, 2)
    }
    
    func testFailedAnalysis() async {
        // Given
        let mockImage = UIImage()
        mockClient.setShouldFail(true)
        
        // When/Then
        do {
            _ = try await service.analyzeSkin(image: mockImage)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is SkinAnalysisError)
        }
    }
}

// MARK: - Mocks
private final class MockNetworkClient {
    private var mockResponse: Any?
    private var shouldFail = false
    
    func setMockResponse(_ response: Any) {
        self.mockResponse = response
    }
    
    func setShouldFail(_ shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    func send<E: BMNetwork.APIEndpoint>(_ request: BMNetwork.APIRequest<E>) async throws -> E.ResponseType {
        if shouldFail {
            throw BMNetwork.APIError.invalidResponse
        }
        guard let response = mockResponse as? E.ResponseType else {
            throw BMNetwork.APIError.decodingError(NSError(domain: "", code: -1))
        }
        return response
    }
}

private final class MockImageUploader: BMNetwork.ImageUploaderProtocol {
    private var mockResponse: BMNetwork.ImgurResponse?
    private var shouldFail = false
    
    func setMockResponse(_ response: BMNetwork.ImgurResponse) {
        self.mockResponse = response
    }
    
    func setShouldFail(_ shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    func uploadImage(_ image: UIImage) async throws -> BMNetwork.ImgurResponse {
        if shouldFail {
            throw BMNetwork.APIError.invalidResponse
        }
        guard let response = mockResponse else {
            throw BMNetwork.APIError.decodingError(NSError(domain: "", code: -1))
        }
        return response
    }
}
#endif
