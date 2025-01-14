import Foundation

@MainActor
public class EncyclopediaViewModel: ObservableObject {
    @Published private(set) var state: ViewState = .idle
    @Published var error: APIError?
    @Published var frontPageContent: FrontPageResponse?
    @Published var currentArticle: EncyclopediaAPI.ArticleResponse?
    
    private let encyclopediaService: EncyclopediaServiceProtocol
    
    public init(encyclopediaService: EncyclopediaServiceProtocol = EncyclopediaService()) {
        self.encyclopediaService = encyclopediaService
    }
    
    public func loadFrontPageContent() async {
        state = .loading
        do {
            let content = try await encyclopediaService.getFrontPageContent()
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
    
    public func loadArticle(id: Int) async {
        state = .loading
        do {
            let article = try await encyclopediaService.getArticle(id: id)
            currentArticle = article
            state = .success(article)
        } catch let error as APIError {
            self.error = error
            state = .error(error)
        } catch {
            let apiError = APIError.networkError(error)
            self.error = apiError
            state = .error(apiError)
        }
    }
    
    public func likeArticle(id: Int) async {
        do {
            try await encyclopediaService.likeArticle(id: id)
            // Reload article to get updated like status
            await loadArticle(id: id)
        } catch let error as APIError {
            self.error = error
        } catch {
            self.error = APIError.networkError(error)
        }
    }
    
    public func visitArticle(id: Int) async {
        do {
            try await encyclopediaService.visitArticle(id: id)
            // Reload article to get updated visit count
            await loadArticle(id: id)
        } catch let error as APIError {
            self.error = error
        } catch {
            self.error = APIError.networkError(error)
        }
    }
}
