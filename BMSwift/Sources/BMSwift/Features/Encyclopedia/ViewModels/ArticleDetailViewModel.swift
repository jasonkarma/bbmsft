import Foundation
import SwiftUI

@MainActor
public final class ArticleDetailViewModel: ObservableObject, Hashable {
    public enum ViewState: Equatable {
        case initial
        case loading
        case loaded(ArticleDetailResponse)
        case error(BMNetwork.APIError)
        
        public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial):
                return true
            case (.loading, .loading):
                return true
            case (.loaded(let lhsArticle), .loaded(let rhsArticle)):
                return lhsArticle.info.bp_subsection_id == rhsArticle.info.bp_subsection_id
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: - Published Properties
    @Published private(set) var state: ViewState = .initial
    @Published private(set) var comments: [Comment] = []
    @Published var commentText: String = ""
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published private(set) var likeMessage: String?
    @Published private(set) var keepMessage: String?
    
    // MARK: - Internal Properties
    nonisolated var token: String { _token }
    
    var articleDetail: ArticleDetailResponse? {
        if case .loaded(let article) = state {
            return article
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    var error: BMNetwork.APIError? {
        if case .error(let error) = state {
            return error
        }
        return nil
    }
    
    // MARK: - Private Properties
    private let articleId: Int
    private let _token: String
    private let encyclopediaService: EncyclopediaServiceProtocol
    private var currentTask: Task<Bool, Never>?
    
    // MARK: - Initialization
    public init(
        articleId: Int,
        token: String,
        encyclopediaService: EncyclopediaServiceProtocol = EncyclopediaService(
            client: BMNetwork.NetworkClient(
                configuration: BMNetwork.Configuration(
                    baseURL: URL(string: "https://wiki.kinglyrobot.com")!,
                    defaultHeaders: [
                        "Content-Type": "application/json"
                    ]
                )
            )
        )
    ) {
        self.articleId = articleId
        self._token = token
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
    @discardableResult
    public func loadContent() async -> Bool {
        currentTask?.cancel()
        
        let task = Task<Bool, Never> { [weak self] in
            guard let self else { return false }
            
            state = .loading
            
            do {
                async let article = encyclopediaService.fetchArticleDetail(id: articleId, authToken: _token)
                async let commentsList = encyclopediaService.fetchComments(articleId: articleId, authToken: _token)
                
                let (articleResult, commentsResult) = try await (article, commentsList)
                guard !Task.isCancelled else { return false }
                
                state = .loaded(articleResult)
                comments = commentsResult
                
                // Record visit
                if !Task.isCancelled {
                    try? await encyclopediaService.visitArticle(id: articleId, authToken: _token)
                }
                
                return true
            } catch let error as BMNetwork.APIError {
                guard !Task.isCancelled else { return false }
                state = .error(error)
                return false
            } catch {
                guard !Task.isCancelled else { return false }
                state = .error(.networkError(error))
                return false
            }
        }
        
        currentTask = task
        return await task.value
    }
    
    @discardableResult
    public func loadContent(forArticleId id: Int) async -> Bool {
        currentTask?.cancel()
        
        let task = Task<Bool, Never> { [weak self] in
            guard let self else { return false }
            
            do {
                async let article = encyclopediaService.fetchArticleDetail(id: id, authToken: _token)
                async let commentsList = encyclopediaService.fetchComments(articleId: id, authToken: _token)
                
                let (articleResult, commentsResult) = try await (article, commentsList)
                guard !Task.isCancelled else { return false }
                
                state = .loaded(articleResult)
                comments = commentsResult
                
                // Record visit
                if !Task.isCancelled {
                    try? await encyclopediaService.visitArticle(id: id, authToken: _token)
                }
                
                return true
            } catch let error as BMNetwork.APIError {
                guard !Task.isCancelled else { return false }
                state = .error(error)
                return false
            } catch {
                guard !Task.isCancelled else { return false }
                state = .error(.networkError(error))
                return false
            }
        }
        
        currentTask = task
        return await task.value
    }
    
    @discardableResult
    public func navigateToArticle(_ id: Int) async -> Bool {
        return await loadContent(forArticleId: id)
    }
    
    // Add debounced toast handling
    private func showToastMessage(_ message: String) {
        // If a toast is already showing, wait for it to finish
        if showToast {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.toastMessage = message
                self.showToast = true
            }
        } else {
            toastMessage = message
            showToast = true
        }
    }
    
    public func submitComment() async {
        guard !commentText.isEmpty else { return }
        
        do {
            try await encyclopediaService.postComment(articleId: articleId, content: commentText, authToken: token)
            commentText = ""
            
            // Just fetch new comments instead of reloading everything
            let newComments = try await encyclopediaService.fetchComments(articleId: articleId, authToken: token)
            comments = newComments
            
            // Show success toast
            withAnimation {
                showToastMessage("發佈成功")
            }
        } catch {
            withAnimation {
                showToastMessage("發佈失敗")
            }
            self.state = .error(error as? BMNetwork.APIError ?? .networkError(error))
        }
    }
    
    public func likeArticle() async {
        guard case .loaded(var article) = state else { return }
        
        do {
            let wasLiked = article.clientsAction.like
            try await encyclopediaService.likeArticle(id: article.info.bp_subsection_id, authToken: token)
            
            // Update the local state with the new like status
            article.clientsAction.like.toggle()
            state = .loaded(article)
            
            // Only show message when liking, not unliking
            if !wasLiked {
                withAnimation {
                    showToastMessage("已點讚")
                }
            }
        } catch {
            print("Error liking article: \(error)")
        }
    }
    
    public func keepArticle() async {
        guard case .loaded(var article) = state else { return }
        
        do {
            let wasKept = article.clientsAction.keep
            try await encyclopediaService.keepArticle(id: article.info.bp_subsection_id, authToken: token)
            
            // Update the local state with the new keep status
            article.clientsAction.keep.toggle()
            state = .loaded(article)
            
            // Only show message when adding to keeps, not removing
            if !wasKept {
                withAnimation {
                    showToastMessage("已添加到收藏")
                }
            }
        } catch {
            print("Error keeping article: \(error)")
        }
    }
}
