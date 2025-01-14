//
// EncyclopediaService.swift
// BMSwift
//
// Created on 2025-01-14
//

import Foundation

/// Protocol defining the Encyclopedia service interface
/// Provides methods for fetching encyclopedia content and managing user interactions
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
    /// - Parameter id: Article identifier
    func likeArticle(id: Int) async throws
    
    /// Records a "visit" interaction for an article
    /// - Parameter id: Article identifier
    func visitArticle(id: Int) async throws
}

/// Implementation of the Encyclopedia service
public final class EncyclopediaService: EncyclopediaServiceProtocol {
    // MARK: - Properties
    
    private let client: NetworkClient
    
    // MARK: - Initialization
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    // MARK: - Encyclopedia Methods
    
    public func getFrontPageContent(authToken: String) async throws -> FrontPageResponse {
        let endpoint = EncyclopediaEndpoints.FrontPage()
        let request = APIRequest(endpoint: endpoint, authToken: authToken)
        return try await client.send(request)
    }
    
    public func getArticle(id: Int, authToken: String) async throws -> ArticleResponse {
        let endpoint = EncyclopediaEndpoints.Article(id: id)
        let request = APIRequest(endpoint: endpoint, authToken: authToken)
        return try await client.send(request)
    }
    
    public func likeArticle(id: Int) async throws {
        let endpoint = EncyclopediaEndpoints.Article(id: id)
        let request = APIRequest(endpoint: endpoint.likeEndpoint)
        _ = try await client.send(request)
    }
    
    public func visitArticle(id: Int) async throws {
        let endpoint = EncyclopediaEndpoints.Article(id: id)
        let request = APIRequest(endpoint: endpoint.visitEndpoint)
        _ = try await client.send(request)
    }
}