import Foundation

@MainActor
public class EncyclopediaViewModel: ObservableObject {
    @Published var hotArticles: [ArticlePreview] = []
    @Published var latestArticles: [ArticlePreview] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiService = EncyclopediaAPIService.shared
    
    public init() {}
    
    public func loadFrontPageContent(token: String) async {
        isLoading = true
        error = nil
        
        do {
            let content = try await apiService.getFrontPageContent(token: token)
            hotArticles = content.hotContents
            latestArticles = content.latestContents
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func getArticleDetail(id: Int, token: String) async throws -> ArticleDetail {
        return try await apiService.getArticleDetail(id: id, token: token)
    }
}
