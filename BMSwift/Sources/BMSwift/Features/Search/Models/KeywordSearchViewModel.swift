import Foundation

@MainActor
@dynamicMemberLookup
final class KeywordSearchViewModel: ObservableObject {
    // Content types
    enum ContentType: Int, CaseIterable {
        case problem = 1     // 問題
        case cause = 2       // 原因
        case method = 3      // 方法
        case suggestion = 4  // 建議
        
        var title: String {
            switch self {
            case .problem: return "問題"
            case .cause: return "原因"
            case .method: return "方法"
            case .suggestion: return "建議"
            }
        }
    }
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
    @Published private(set) var searchResults: [Search.SearchArticle] = []
    
    // Computed property to check if search can be performed
    var canSearch: Bool {
        selectedHashtag != nil && selectedType != nil
    }
    private let encyclopediaService: EncyclopediaServiceProtocol
    private let searchService: SearchServiceProtocol
    private let encyclopediaViewModel: EncyclopediaViewModel
    let token: String
    
    init(service: EncyclopediaServiceProtocol, token: String, encyclopediaViewModel: EncyclopediaViewModel) {
        self.encyclopediaService = service
        self.searchService = SearchService(client: .shared)
        self.token = token
        self.encyclopediaViewModel = encyclopediaViewModel
    }
    
    func loadKeywords() async {
        state = .loading
        
        // Try to use preloaded data first
        if !encyclopediaViewModel.hotKeywords.isEmpty {
            self.hotKeywords = encyclopediaViewModel.hotKeywords
            self.allKeywords = encyclopediaViewModel.allKeywords
            self.state = .loaded
            return
        }
        
        // Fall back to loading from API if preloaded data is not available
        do {
            let keywords = try await encyclopediaService.getKeywords(authToken: token)
            self.hotKeywords = keywords.hot
            self.allKeywords = keywords.all
            self.state = .loaded
        } catch {
            self.state = .error(error)
        }
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
    
    func performSearch() async {
        guard let hashtag = selectedHashtag,
              let type = selectedType,
              let keyword = allKeywords.first(where: { $0.bp_hashtag == hashtag }) else {
            print("[KeywordSearchViewModel] Cannot search: hashtag=\(selectedHashtag ?? "nil"), type=\(selectedType ?? -1)")
            return
        }
        print("[KeywordSearchViewModel] Performing search with hashtag=\(hashtag), type=\(type), tagId=\(keyword.bp_tag_id)")
        
        state = .loading
        do {
            let response = try await searchService.searchContent(
                tagId: keyword.bp_tag_id,
                type: type,
                authToken: token
            )
            
            // Update encyclopedia view model with search results
            print("[KeywordSearchViewModel] Search successful with \(response.contents.data.count) results")
            self.searchResults = response.contents.data
            encyclopediaViewModel.updateWithSearchResults(response.contents.data)
            state = .loaded
        } catch {
            print("[KeywordSearchViewModel] Search failed: \(error)")
            state = .error(error)
        }
    }

    
    subscript<T>(dynamicMember keyPath: KeyPath<KeywordSearchViewModel, T>) -> T {
        self[keyPath: keyPath]
    }
}
