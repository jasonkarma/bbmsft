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
    @Published private(set) var selectedHashtag: String?
    @Published private(set) var selectedType: Int?
    
    private let service: EncyclopediaServiceProtocol
    private let token: String
    private let encyclopediaViewModel: EncyclopediaViewModel
    
    init(service: EncyclopediaServiceProtocol, token: String, encyclopediaViewModel: EncyclopediaViewModel) {
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
    
    func selectHashtag(_ hashtag: String) {
        if selectedHashtag == hashtag {
            selectedHashtag = nil
            // Clear type when deselecting hashtag
            selectedType = nil
        } else {
            selectedHashtag = hashtag
        }
    }
    
    func selectType(_ type: Int) {
        if selectedType == type {
            selectedType = nil
        } else {
            selectedType = type
            // Ensure we have a hashtag selected
            if selectedHashtag == nil {
                // Optionally show a toast or alert here
                print("Please select a hashtag first")
            }
        }
    }
}
