//
// EncyclopediaViewModel.swift
// BMSwift
//
// Created on 2025-01-14
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let loadMoreResults = Notification.Name("loadMoreResults")
}

/// View model for the encyclopedia view
/// Manages the state and business logic for encyclopedia content
@MainActor
public final class EncyclopediaViewModel: ObservableObject {
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
    @Published public var hotArticles: [ArticlePreview] = [] 
    
    /// Latest articles from front page
    @Published private(set) var latestArticles: [ArticlePreview] = []
    
    /// Search results
    @Published private(set) var searchResults: [Search.SearchArticle] = []
    
    /// Whether we're currently showing search results
    @Published private(set) var isShowingSearchResults = false
    
    /// Loading state
    @Published private(set) var isLoading: Bool = false
    
    /// Showing skin analysis state
    @Published var showingSkinAnalysis = false
    
    /// Current search source
    private(set) var currentSearchSource: SearchSource = .none
    
    /// Load more search results when scrolling
    public func loadMoreResults() async {
        print("[Encyclopedia] Requesting to load more results from source: \(currentSearchSource)")
        NotificationCenter.default.post(name: .loadMoreResults, object: nil, userInfo: ["source": currentSearchSource])
    }
    
    /// Update the current search source
    public func updateSearchSource(_ source: SearchSource) {
        print("[Encyclopedia] Updating search source to: \(source)")
        currentSearchSource = source
    }
    
    /// Search source enum
    public enum SearchSource: CustomStringConvertible {
        case keyword
        case voice
        case none
        
        public var description: String {
            switch self {
            case .keyword: return "keyword"
            case .voice: return "voice"
            case .none: return "none"
            }
        }
    }
    
    // Store preloaded keyword data
    private(set) var hotKeywords: [KeywordModel] = []
    private(set) var allKeywords: [KeywordModel] = []
    private(set) var keywordsLoaded = false
    

    // MARK: - Search Functionality
    
    // MARK: - Pagination State
    
    /// Current page number for search results
    @Published private(set) var currentPage: Int = 1
    
    /// Last available page number
    @Published private(set) var lastPage: Int = 1
    
    /// Whether we can load more pages
    public var canLoadMore: Bool {
        currentPage < lastPage && !searchResults.isEmpty
    }
    
    /// Whether we're currently loading more results
    @Published private(set) var isLoadingMore = false
    
    /// Update the view with search results
    /// - Parameters:
    ///   - results: Array of search results
    ///   - page: Current page number
    ///   - lastPage: Last available page
    ///   - append: Whether to append results or replace existing ones
    public func updateWithSearchResults(
        _ results: [Search.SearchArticle],
        page: Int,
        lastPage: Int,
        append: Bool = false
    ) {
        print("[Encyclopedia] Updating search results - page: \(page), lastPage: \(lastPage), append: \(append), results count: \(results.count)")
        print("[Encyclopedia] Current state - currentPage: \(currentPage), lastPage: \(lastPage), searchResults count: \(searchResults.count)")
        
        // Update pagination state
        self.currentPage = page
        self.lastPage = lastPage
        self.isLoadingMore = false
        
        // Update results
        if append {
            print("[Encyclopedia] Appending \(results.count) results to existing \(searchResults.count) results")
            self.searchResults.append(contentsOf: results)
        } else {
            print("[Encyclopedia] Replacing results with \(results.count) new results")
            self.searchResults = results
        }
        
        print("[Encyclopedia] Final state - searchResults count: \(searchResults.count), canLoadMore: \(canLoadMore)")
        self.isShowingSearchResults = true
        
        // Convert search articles to article previews for the hot articles section
        let articlePreviews = results.map { searchArticle in
            ArticlePreview(
                id: searchArticle.id,
                title: searchArticle.title,
                intro: searchArticle.intro,
                mediaName: searchArticle.mediaName,
                visitCount: searchArticle.visitCount,
                likeCount: searchArticle.likeCount,
                platform: 0,  // Default platform
                clientLike: false,
                clientVisit: false,
                clientKeep: false
            )
        }
        
        if append {
            self.hotArticles.append(contentsOf: articlePreviews)
        } else {
            self.hotArticles = articlePreviews
        }
    }
    
    /// Clear search results and restore hot articles
    public func clearSearchResults() {
        self.searchResults = []
        self.isShowingSearchResults = false
        // Restore hot articles from front page content if available
        if let content = frontPageContent {
            self.hotArticles = content.hotContents
        }
    }
    
    // MARK: - Dependencies
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
            
            // Preload keywords after content loads
            if !keywordsLoaded {
                await preloadKeywords()
            }
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
    
    /// Preloads keywords
    func preloadKeywords() async {
        do {
            let keywords = try await encyclopediaService.getKeywords(authToken: token)
            self.hotKeywords = keywords.hot
            self.allKeywords = keywords.all
            self.keywordsLoaded = true
        } catch {
            print("[EncyclopediaViewModel] Failed to preload keywords: \(error)")
        }
    }
    
    /// Gets preloaded keywords
    func getPreloadedKeywords() -> (hot: [KeywordModel], all: [KeywordModel])? {
        guard keywordsLoaded else { return nil }
        return (hot: hotKeywords, all: allKeywords)
    }
    
    // MARK: - View State
    public enum ViewState {
        case idle
        case loading
        case success(Any)
        case error(Error)
    }
}
