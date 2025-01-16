import Foundation
import SwiftUI

@MainActor
public final class ArticleDetailViewModel: ObservableObject, Hashable {
    // MARK: - Published Properties
    @Published private(set) var articleDetail: ArticleDetailResponse?
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var isLoading: Bool = false
    @Published var error: BMNetwork.APIError?
    @Published var commentText: String = ""
    
    // MARK: - Private Properties
    private let articleId: Int
    private let token: String
    private let encyclopediaService: EncyclopediaServiceProtocol
    
    // MARK: - Initialization
    public init(
        articleId: Int,
        token: String,
        encyclopediaService: EncyclopediaServiceProtocol = EncyclopediaService(client: BMNetwork.NetworkClient(baseURL: URL(string: "https://wiki.kinglyrobot.com")!))
    ) {
        self.articleId = articleId
        self.token = token
        self.encyclopediaService = encyclopediaService
    }
    
    // MARK: - Hashable Conformance
    nonisolated public static func == (lhs: ArticleDetailViewModel, rhs: ArticleDetailViewModel) -> Bool {
        lhs.articleId == rhs.articleId && lhs.token == rhs.token
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(articleId)
        hasher.combine(token)
    }
    
    // MARK: - Public Methods
    public func loadContent() async {
        print("ArticleDetailViewModel: Starting content load")
        isLoading = true
        error = nil
        
        do {
            print("ArticleDetailViewModel: Fetching article and comments")
            let article = try await encyclopediaService.fetchArticleDetail(id: articleId, authToken: token)
            self.articleDetail = article
            
            // Fetch comments separately to avoid any potential issues
            do {
                let comments = try await encyclopediaService.fetchComments(articleId: articleId, authToken: token)
                self.comments = comments
            } catch {
                print("ArticleDetailViewModel: Error fetching comments - \(error)")
                // Don't fail the whole view if comments fail to load
                self.comments = []
            }
            
            print("ArticleDetailViewModel: Successfully loaded article")
        } catch {
            print("ArticleDetailViewModel: Error loading content - \(error)")
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
        
        isLoading = false
        print("ArticleDetailViewModel: Finished loading. hasError: \(error != nil), hasContent: \(articleDetail != nil)")
    }
    
    public func submitComment() async {
        guard !commentText.isEmpty else { return }
        
        do {
            try await encyclopediaService.postComment(articleId: articleId, content: commentText, authToken: token)
            commentText = ""
            await loadContent()
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
    }
    
    public func likeArticle() async {
        do {
            try await encyclopediaService.likeArticle(id: articleId, authToken: token)
            await loadContent()
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
    }
    
    public func keepArticle() async {
        do {
            try await encyclopediaService.keepArticle(id: articleId, authToken: token)
            await loadContent()
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
    }
}
