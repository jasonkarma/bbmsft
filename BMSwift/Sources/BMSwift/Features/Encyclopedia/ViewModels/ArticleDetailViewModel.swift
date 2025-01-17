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
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published private(set) var likeMessage: String?
    @Published private(set) var keepMessage: String?
    
    // MARK: - Private Properties
    private let articleId: Int
    private let token: String
    private let encyclopediaService: EncyclopediaServiceProtocol
    private var currentTask: Task<Void, Never>?
    
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
        // Cancel any existing task
        currentTask?.cancel()
        
        let task = Task {
            guard !isLoading else { return }
            
            isLoading = true
            error = nil
            
            do {
                // Load article first
                let article = try await encyclopediaService.fetchArticleDetail(id: articleId, authToken: token)
                if Task.isCancelled { return }
                self.articleDetail = article
                
                // Then load comments
                let commentsList = try await encyclopediaService.fetchComments(articleId: articleId, authToken: token)
                if Task.isCancelled { return }
                self.comments = commentsList
                
                // Record visit
                if !Task.isCancelled {
                    try? await encyclopediaService.visitArticle(id: articleId, authToken: token)
                }
                
            } catch let networkError as BMNetwork.APIError {
                if !Task.isCancelled {
                    error = networkError
                }
            } catch {
                if !Task.isCancelled {
                    self.error = .networkError(error)
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
        
        currentTask = task
        await task.value
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
        guard let id = articleDetail?.info.bp_subsection_id else { return }
        do {
            let wasLiked = articleDetail?.clientsAction.like ?? false
            try await encyclopediaService.likeArticle(id: id, authToken: token)
            articleDetail?.clientsAction.like.toggle()
            
            // Only show message when adding like, not removing
            if !wasLiked {
                toastMessage = "已添加到喜歡"
                withAnimation {
                    showToast = true
                }
            }
        } catch {
            print("Error liking article: \(error)")
            // Revert the state if there was an error
            articleDetail?.clientsAction.like = false
        }
    }
    
    public func keepArticle() async {
        guard let id = articleDetail?.info.bp_subsection_id else { return }
        do {
            let wasKept = articleDetail?.clientsAction.keep ?? false
            try await encyclopediaService.keepArticle(id: id, authToken: token)
            articleDetail?.clientsAction.keep.toggle()
            
            // Only show message when adding to keeps, not removing
            if !wasKept {
                toastMessage = "已添加到收藏"
                withAnimation {
                    showToast = true
                }
            }
        } catch {
            print("Error keeping article: \(error)")
            // Revert the state if there was an error
            articleDetail?.clientsAction.keep = false
        }
    }
}
