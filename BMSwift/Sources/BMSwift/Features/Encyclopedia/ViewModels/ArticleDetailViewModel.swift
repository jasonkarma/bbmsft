import Foundation
import SwiftUI

@MainActor
public final class ArticleDetailViewModel: ObservableObject {
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
    
    // MARK: - Public Methods
    public func loadContent() async {
        isLoading = true
        error = nil
        
        do {
            async let articleTask = encyclopediaService.fetchArticleDetail(id: articleId, authToken: token)
            async let commentsTask = encyclopediaService.fetchComments(articleId: articleId, authToken: token)
            
            let (article, comments) = try await (articleTask, commentsTask)
            self.articleDetail = article
            self.comments = comments
            
        } catch {
            self.error = error as? BMNetwork.APIError ?? .networkError(error)
        }
        
        isLoading = false
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
