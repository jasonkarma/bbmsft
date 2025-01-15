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
}

/// Implementation of the Encyclopedia service
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
}