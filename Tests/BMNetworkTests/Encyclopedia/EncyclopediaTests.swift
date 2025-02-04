import XCTest
@testable import BMNetwork

final class EncyclopediaTests: XCTestCase {
    // MARK: - Test Properties
    
    private var client: MockNetworkClient!
    private var tokenManager: MockTokenManager!
    private var service: BMNetworkV2.Encyclopedia.Service!
    
    // MARK: - Setup
    
    override func setUp() async throws {
        try await super.setUp()
        client = MockNetworkClient()
        tokenManager = MockTokenManager()
        service = try BMNetworkV2.Encyclopedia.Service(client: client, tokenManager: tokenManager)
        
        // Register types
        BMNetworkV2.Encyclopedia.register()
    }
    
    // MARK: - Front Page Tests
    
    func testGetFrontPage() async throws {
        // Given
        let expectedResponse = BMNetworkV2.FrontPageResponse(
            hotContents: [
                .init(id: 1, title: "Hot Article", imageUrl: nil, likes: 100, views: 1000, createdAt: Date())
            ],
            latestContents: [
                .init(id: 2, title: "Latest Article", imageUrl: nil, likes: 50, views: 500, createdAt: Date())
            ]
        )
        client.mockResponse(expectedResponse, for: BMNetworkV2.Encyclopedia.Endpoints.FrontPage())
        
        // When
        let response = try await service.getFrontPage()
        
        // Then
        XCTAssertEqual(response.hotContents.count, 1)
        XCTAssertEqual(response.latestContents.count, 1)
        XCTAssertEqual(response.hotContents[0].title, "Hot Article")
        XCTAssertEqual(response.latestContents[0].title, "Latest Article")
    }
    
    // MARK: - Article Tests
    
    func testGetArticle() async throws {
        // Given
        let expectedResponse = BMNetworkV2.ArticleResponse(
            id: 1,
            title: "Test Article",
            content: "Article content",
            imageUrl: nil,
            likes: 100,
            views: 1000
        )
        client.mockResponse(expectedResponse, for: BMNetworkV2.Encyclopedia.Endpoints.Article(id: 1))
        
        // When
        let response = try await service.getArticle(id: 1)
        
        // Then
        XCTAssertEqual(response.id, 1)
        XCTAssertEqual(response.title, "Test Article")
        XCTAssertEqual(response.content, "Article content")
    }
    
    // MARK: - Like Tests
    
    func testLikeArticle() async throws {
        // Given
        let expectedResponse = BMNetworkV2.LikeActionResponse(success: true, message: "Liked!")
        client.mockResponse(expectedResponse, for: BMNetworkV2.Encyclopedia.Endpoints.LikeArticle())
        
        // When
        let response = try await service.likeArticle(id: 1)
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Liked!")
    }
    
    // MARK: - Comment Tests
    
    func testGetComments() async throws {
        // Given
        let comment = BMNetworkV2.Comment(
            id: 1,
            content: "Test comment",
            userId: 1,
            username: "user1",
            createdAt: Date()
        )
        let expectedResponse = BMNetworkV2.CommentResponse(comments: [comment], total: 1)
        client.mockResponse(expectedResponse, for: BMNetworkV2.Encyclopedia.Endpoints.Comments(id: 1))
        
        // When
        let response = try await service.getComments(articleId: 1)
        
        // Then
        XCTAssertEqual(response.comments.count, 1)
        XCTAssertEqual(response.total, 1)
        XCTAssertEqual(response.comments[0].content, "Test comment")
    }
    
    func testPostComment() async throws {
        // Given
        let expectedResponse = BMNetworkV2.ClientActionResponse(success: true, message: "Comment posted!")
        client.mockResponse(expectedResponse, for: BMNetworkV2.Encyclopedia.Endpoints.PostComment())
        
        // When
        let response = try await service.postComment(content: "New comment", articleId: 1)
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Comment posted!")
    }
    
    // MARK: - Type Safety Tests
    
    func testTypeConversion() throws {
        // Given
        let preview = BMNetworkV2.ArticlePreview(
            id: 1,
            title: "Test",
            imageUrl: nil,
            likes: 100,
            views: 1000,
            createdAt: Date()
        )
        
        // When/Then
        XCTAssertNoThrow(try preview.convert(to: BMNetworkV2.ArticleResponse.self))
    }
    
    func testInvalidTypeConversion() throws {
        // Given
        let preview = BMNetworkV2.ArticlePreview(
            id: 1,
            title: "Test",
            imageUrl: nil,
            likes: 100,
            views: 1000,
            createdAt: Date()
        )
        
        // When/Then
        XCTAssertThrowsError(try preview.convert(to: BMNetworkV2.CommentResponse.self))
    }
}

// MARK: - Test Helpers

private final class MockNetworkClient: NetworkClient {
    private var responses: [String: Any] = [:]
    
    func mockResponse<E: APIEndpoint>(_ response: E.ResponseType, for endpoint: E) {
        responses[String(describing: type(of: endpoint))] = response
    }
    
    override func send<E>(_ endpoint: E, body: E.RequestType?, token: String?) async throws -> E.ResponseType where E : APIEndpoint {
        guard let response = responses[String(describing: type(of: endpoint))] as? E.ResponseType else {
            throw BMNetworkV2.RuntimeError.typeConflict(type: String(describing: E.self), feature: "test")
        }
        return response
    }
}

private final class MockTokenManager: TokenManagerProtocol {
    func getToken() throws -> String {
        return "mock_token"
    }
    
    func clearToken() {}
}
