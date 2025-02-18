import Foundation

@MainActor
public extension BMSearchV2.Search {
    final class KeywordSearchViewModel: ObservableObject {
        enum ViewState {
            case loading
            case loaded
            case error(Error)
        }
        
        // MARK: - Published Properties
        @Published private(set) var state: ViewState = .loaded
        @Published private(set) var searchResults: [SearchArticle] = []
        @Published private(set) var hotKeywords: [String] = []
        @Published private(set) var allKeywords: [String] = []
        @Published var selectedType: SearchType = .type1
        @Published var selectedKeyword: String = ""
        
        // MARK: - Public Properties
        let searchTypes = SearchType.allCases
        
        // MARK: - Dependencies
        private let keywordsService: KeywordsServiceProtocol
        private let searchService: SearchServiceProtocol
        let token: String
        
        // MARK: - Initialization
        init(keywordsService: KeywordsServiceProtocol, searchService: SearchServiceProtocol, token: String) {
            self.keywordsService = keywordsService
            self.searchService = searchService
            self.token = token
            Task {
                await loadKeywords()
            }
        }
        
        // MARK: - Public Methods
        
        /// Load both hot and all keywords
        func loadKeywords() async {
            do {
                async let hotResponse = keywordsService.getHotKeywords(authToken: token)
                async let allResponse = keywordsService.getAllKeywords(authToken: token)
                
                let (hot, all) = try await (hotResponse, allResponse)
                print("[KeywordSearch] Loaded \(hot.keywords.count) hot keywords and \(all.keywords.count) total keywords")
                
                hotKeywords = hot.keywords
                allKeywords = all.keywords
                
                // Select first keyword if available
                if let firstHot = hot.keywords.first {
                    selectedKeyword = firstHot
                }
            } catch {
                print("[KeywordSearch] Failed to load keywords: \(error)")
                hotKeywords = []
                allKeywords = []
            }
        }
        
        /// Search for articles using the current type and keyword
        func performSearch() {
            guard !selectedKeyword.isEmpty else { return }
            
            print("[KeywordSearch] Starting search with type: \(selectedType), keyword: \(selectedKeyword)")
            
            Task {
                do {
                    state = .loading
                    let response = try await searchService.searchArticles(
                        type: selectedType,
                        bpTagId: selectedKeyword,
                        page: 1,
                        authToken: token
                    )
                    print("[KeywordSearch] Found \(response.contents.data.count) articles")
                    searchResults = response.contents.data
                    state = .loaded
                } catch {
                    print("[KeywordSearch] Search failed: \(error)")
                    state = .error(error)
                    searchResults = []
                }
            }
        }
        
        /// Update selected search type and perform search
        func selectType(_ type: SearchType) {
            selectedType = type
            performSearch()
        }
        
        /// Update selected keyword and perform search
        func selectKeyword(_ keyword: String) {
            selectedKeyword = keyword
            performSearch()
        }
    }
}
