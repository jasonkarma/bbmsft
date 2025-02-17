//
// EncyclopediaService.swift
// BMSwift
//
// Created on 2025-01-14
//

import Foundation

/// Protocol defining the encyclopedia service interface
public protocol EncyclopediaServiceProtocol {
    /// Fetches the front page content
    /// - Parameter authToken: Authentication token for the request
    /// - Returns: FrontPageResponse containing the content
    func getFrontPageContent(authToken: String) async throws -> FrontPageResponse
    
    /// Fetches a specific article by ID
    /// - Parameters:
    ///   - id: Article identifier
    ///   - authToken: Authentication token for the request
    /// - Returns: ArticleResponse containing the article content
    func getArticle(id: Int, authToken: String) async throws -> ArticleResponse
    
    /// Records a "like" interaction for an article
    /// - Parameters:
    ///   - id: Article identifier
    ///   - authToken: Authentication token for the request
    func likeArticle(id: Int, authToken: String) async throws
    
    /// Records a "visit" interaction for an article
    /// - Parameters:
    ///   - id: Article identifier
    ///   - authToken: Authentication token for the request
    func visitArticle(id: Int, authToken: String) async throws
    
    /// Fetches detailed content for an article
    /// - Parameters:
    ///   - id: Article identifier
    ///   - authToken: Authentication token for the request
    /// - Returns: ArticleDetailResponse containing the full article content
    func fetchArticleDetail(id: Int, authToken: String) async throws -> ArticleDetailResponse
    
    /// Fetches comments for an article
    /// - Parameters:
    ///   - articleId: Article identifier
    ///   - authToken: Authentication token for the request
    /// - Returns: Array of comments
    func fetchComments(articleId: Int, authToken: String) async throws -> [Comment]
    
    /// Posts a new comment
    /// - Parameters:
    ///   - articleId: Article identifier
    ///   - content: Comment content
    ///   - authToken: Authentication token for the request
    func postComment(articleId: Int, content: String, authToken: String) async throws
    
    /// Adds article to favorites
    /// - Parameters:
    ///   - id: Article identifier
    ///   - authToken: Authentication token for the request
    func keepArticle(id: Int, authToken: String) async throws
    
    /// Fetches user profile
    /// - Parameter token: Authentication token for the request
    /// - Returns: ProfileResponse containing the user's profile information
    func fetchProfile(token: String) async throws -> ProfileResponse
    
    /// Fetches keywords for encyclopedia
    /// - Parameter authToken: Authentication token for the request
    /// - Returns: KeywordResponse containing hot and all keywords
    func getKeywords(authToken: String) async throws -> KeywordResponse
}

/// Implementation of the encyclopedia service
public final class EncyclopediaService: EncyclopediaServiceProtocol {
    // MARK: - Properties
    
    private let client: BMNetwork.NetworkClient
    
    // MARK: - Initialization
    
    public init(client: BMNetwork.NetworkClient) {
        self.client = client
    }
    
    // MARK: - Encyclopedia Methods
    
    public func getFrontPageContent(authToken: String) async throws -> FrontPageResponse {
        print("[Encyclopedia] Getting front page content...")
        let request = EncyclopediaEndpoints.frontPage(authToken: authToken)
        return try await client.send(request)
    }
    
    public func getArticle(id: Int, authToken: String) async throws -> ArticleResponse {
        print("[Encyclopedia] Getting article \(id)...")
        let request = EncyclopediaEndpoints.article(id: id, authToken: authToken)
        return try await client.send(request)
    }
    
    public func likeArticle(id: Int, authToken: String) async throws {
        print("[Encyclopedia] Liking article \(id)...")
        let request = EncyclopediaEndpoints.like(id: id, authToken: authToken)
        _ = try await client.send(request)
    }
    
    public func visitArticle(id: Int, authToken: String) async throws {
        print("[Encyclopedia] Recording visit to article \(id)...")
        let request = EncyclopediaEndpoints.visit(id: id, authToken: authToken)
        _ = try await client.send(request)
    }
    
    // MARK: - Article Detail Methods
    
    public func fetchArticleDetail(id: Int, authToken: String) async throws -> ArticleDetailResponse {
        print("[Encyclopedia] Fetching article detail \(id)...")
        let request = EncyclopediaEndpoints.articleDetail(id: id, authToken: authToken)
        return try await client.send(request)
    }
    
    public func fetchComments(articleId: Int, authToken: String) async throws -> [Comment] {
        print("[Encyclopedia] Fetching comments for article \(articleId)...")
        let request = EncyclopediaEndpoints.comments(id: articleId, authToken: authToken)
        let response = try await client.send(request)
        return response.comments
    }
    
    public func postComment(articleId: Int, content: String, authToken: String) async throws {
        print("[Encyclopedia] Posting comment for article \(articleId)...")
        let request = EncyclopediaEndpoints.postComment(articleId: articleId, content: content, authToken: authToken)
        _ = try await client.send(request)
    }
    
    public func keepArticle(id: Int, authToken: String) async throws {
        print("[Encyclopedia] Keeping article \(id)...")
        let request = EncyclopediaEndpoints.keep(id: id, authToken: authToken)
        _ = try await client.send(request)
    }
    
    public func fetchProfile(token: String) async throws -> ProfileResponse {
        let request = EncyclopediaEndpoints.profile(token: token)
        return try await client.send(request)
    }
    
    public func getKeywords(authToken: String) async throws -> KeywordResponse {
        // Load both keyword lists concurrently
        async let allKeywordsTask = client.send(EncyclopediaEndpoints.allKeywords(authToken: authToken))
        async let hotKeywordsTask = client.send(EncyclopediaEndpoints.hotKeywords(authToken: authToken))
        
        // Await both results
        let (allKeywords, hotKeywords) = try await (allKeywordsTask, hotKeywordsTask)
        
        // Convert to KeywordResponse
        return KeywordResponse(
            hot: hotKeywords.map { KeywordModel(bp_tag_id: $0.bp_tag_id, bp_hashtag: $0.bp_hashtag, content_count: $0.content_hashtag_count) },
            all: allKeywords.map { KeywordModel(bp_tag_id: $0.bp_tag_id, bp_hashtag: $0.bp_hashtag, content_count: $0.content_count) }
        )
    }
}