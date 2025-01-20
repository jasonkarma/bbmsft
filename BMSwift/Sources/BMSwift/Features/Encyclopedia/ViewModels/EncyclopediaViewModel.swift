//
// EncyclopediaViewModel.swift
// BMSwift
//
// Created on 2025-01-14
//

import Foundation
import SwiftUI

/// View model for the encyclopedia view
/// Manages the state and business logic for encyclopedia content
@MainActor
public class EncyclopediaViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current state of the view
    @Published private(set) var state: ViewState = .idle
    
    /// Current error if any
    @Published var error: BMNetwork.APIError?
    
    /// Front page content
    @Published var frontPageContent: FrontPageResponse?
    
    /// Currently displayed article
    @Published var currentArticle: ArticleResponse?
    
    /// Hot articles from front page
    @Published private(set) var hotArticles: [ArticlePreview] = []
    
    /// Latest articles from front page
    @Published private(set) var latestArticles: [ArticlePreview] = []
    
    /// Loading state
    @Published private(set) var isLoading: Bool = false
    
    /// Showing skin analysis state
    @Published var showingSkinAnalysis = false
    
    // MARK: - Private Properties
    private let encyclopediaService: EncyclopediaServiceProtocol
    private let authActor: AuthenticationActor
    private let token: String
    
    // MARK: - Initialization
    
    /// Creates a new instance of EncyclopediaViewModel
    /// - Parameters:
    ///   - token: Authentication token for API requests
    ///   - client: Network client for making API requests
    ///   - authActor: Actor for handling authentication state
    public init(
        token: String,
        client: BMNetwork.NetworkClient = BMNetwork.NetworkClient.shared,
        authActor: AuthenticationActor = .shared
    ) {
        print("[Encyclopedia] Initializing with token: \(token.prefix(10))...")
        self.token = token
        self.encyclopediaService = EncyclopediaService(client: client)
        self.authActor = authActor
    }
    
    // MARK: - Public Methods
    
    /// Loads the front page content
    public func loadFrontPageContent() async {
        print("[Encyclopedia] Loading front page content...")
        isLoading = true
        state = .loading
        
        do {
            let content = try await encyclopediaService.getFrontPageContent(authToken: token)
            print("[Encyclopedia] Content loaded successfully")
            frontPageContent = content
            hotArticles = content.hotContents
            latestArticles = content.latestContents
            state = .success(content)
        } catch {
            print("[Encyclopedia] Failed to load content: \(error)")
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
            state = .error(self.error!)
        }
        
        isLoading = false
    }
    
    /// Loads a specific article
    public func loadArticle(id: Int) async {
        isLoading = true
        state = .loading
        
        do {
            let article = try await encyclopediaService.getArticle(id: id, authToken: token)
            currentArticle = article
            state = .success(article)
            
            // Record the visit
            await visitArticle(id: id)
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
            state = .error(self.error!)
        }
        
        isLoading = false
    }
    
    /// Likes an article
    public func likeArticle(id: Int) async {
        do {
            try await encyclopediaService.likeArticle(id: id, authToken: token)
            // Optionally refresh the article to show updated like status
            await loadArticle(id: id)
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
    }
    
    /// Records a visit to an article
    public func visitArticle(id: Int) async {
        do {
            try await encyclopediaService.visitArticle(id: id, authToken: token)
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
    }
    
    // MARK: - View State
    public enum ViewState {
        case idle
        case loading
        case success(Any)
        case error(Error)
    }
}