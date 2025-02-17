import Foundation

@MainActor
final class KeywordSearchViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error(Error)
    }
    
    @Published private(set) var state: ViewState = .loading
    @Published private(set) var hotKeywords: [KeywordModel] = []
    @Published private(set) var allKeywords: [KeywordModel] = []
    
    private let service: EncyclopediaService
    private let token: String
    private let encyclopediaViewModel: EncyclopediaViewModel
    
    init(service: EncyclopediaService, token: String, encyclopediaViewModel: EncyclopediaViewModel) {
        self.service = service
        self.token = token
        self.encyclopediaViewModel = encyclopediaViewModel
    }
    
    func loadKeywords() async {
        state = .loading
        
        // Try to use preloaded data first
        if let preloaded = encyclopediaViewModel.getPreloadedKeywords() {
            self.hotKeywords = preloaded.hot
            self.allKeywords = preloaded.all
            self.state = .loaded
            return
        }
        
        // Fall back to loading from API if preloaded data is not available
        do {
            let keywords = try await service.getKeywords(authToken: token)
            self.hotKeywords = keywords.hot
            self.allKeywords = keywords.all
            self.state = .loaded
        } catch {
            self.state = .error(error)
        }
    }
    
    func keywordSelected(_ keyword: KeywordModel) {
        // Handle keyword selection
    }
}
