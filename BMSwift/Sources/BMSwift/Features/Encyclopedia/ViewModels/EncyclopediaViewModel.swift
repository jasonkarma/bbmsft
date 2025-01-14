//
// EncyclopediaViewModel.swift
// BMSwift
//
// Created on 2025-01-14
//

import Foundation

/// View model for the Encyclopedia feature
/// Manages the state and business logic for encyclopedia content
@MainActor
public final class EncyclopediaViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current state of the view
    @Published private(set) var state: ViewState = .idle
    
    /// Current error if any
    @Published var error: APIError?
    
    /// Front page content
    @Published var frontPageContent: FrontPageResponse?
    
    /// Currently displayed article
    @Published var currentArticle: ArticleResponse?
    
    // MARK: - Private Properties
    
    private let encyclopediaService: EncyclopediaServiceProtocol
    private let authManager: AuthManagerProtocol
    
    // MARK: - Initialization
    
    /// Creates a new instance of EncyclopediaViewModel
    /// - Parameters:
    ///   - encyclopediaService: Service for fetching encyclopedia content
    ///   - authManager: Manager for handling authentication state
    public init(
        encyclopediaService: EncyclopediaServiceProtocol,
        authManager: AuthManagerProtocol
    ) {
        self.encyclopediaService = encyclopediaService
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    
    /// Loads the front page content
    public func loadFrontPageContent() async {
        state = .loading
        
        do {
            guard let authToken = authManager.currentToken else {
                throw APIError.unauthorized
            }
            
            let content = try await encyclopediaService.getFrontPageContent(authToken: authToken)
            frontPageContent = content
            state = .success(content)
        } catch let error as APIError {
            self.error = error
            state = .error(error)
        } catch {
            let apiError = APIError.networkError(error)
            self.error = apiError
            state = .error(apiError)
        }
    }
    
    /// Loads a specific article
    /// - Parameter id: Article identifier
    public func loadArticle(id: Int) async {
        state = .loading
        
        do {
            guard let authToken = authManager.currentToken else {
                throw APIError.unauthorized
            }
            
            let article = try await encyclopediaService.getArticle(id: id, authToken: authToken)
            currentArticle = article
            state = .success(article)
            
            // Record the visit
            try await encyclopediaService.visitArticle(id: id)
        } catch let error as APIError {
            self.error = error
            state = .error(error)
        } catch {
            let apiError = APIError.networkError(error)
            self.error = apiError
            state = .error(apiError)
        }
    }
    
    /// Likes an article
    /// - Parameter id: Article identifier
    public func likeArticle(id: Int) async {
        do {
            try await encyclopediaService.likeArticle(id: id)
        } catch {
            self.error = APIError.networkError(error)
        }
    }
}

// MARK: - View State

extension EncyclopediaViewModel {
    /// Represents the different states of the view
    enum ViewState {
        case idle
        case loading
        case success(Any)
        case error(Error)
    }
}