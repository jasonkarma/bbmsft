import Foundation


@MainActor
public extension BMSearchV2.Search {
    final class SearchViewModel: ObservableObject {
        enum ViewState {
            case loading
            case loaded
            case error(Error)
        }
        
        // MARK: - Published Properties
        @Published private(set) var state: ViewState = .loaded
        @Published private(set) var searchResults: [SearchResponse.SearchArticle] = []
        @Published var selectedType: SearchType = .type1
        @Published private(set) var hotKeywords: [String] = []
        @Published private(set) var allKeywords: [String] = []
        @Published var selectedKeyword: String = ""
        
        // MARK: - Public Properties
        let searchTypes = SearchType.allCases
        
        // MARK: - Dependencies
        private let searchService: SearchServiceProtocol
        private let keywordsService: KeywordsServiceProtocol
        let token: String
        
        // MARK: - Initialization
        nonisolated init(searchService: SearchServiceProtocol = SearchService(client: .shared),
             keywordsService: KeywordsServiceProtocol = KeywordsService(client: .shared),
             token: String) {
            self.searchService = searchService
            self.keywordsService = keywordsService
            self.token = token
            
            // Load keywords on initialization
            Task { @MainActor in
                await loadKeywords()
            }
        }
        
        // MARK: - Public Methods
        
        /// Load both hot and all keywords
        @MainActor
        func loadKeywords() async {
            do {
                async let hotResponse = keywordsService.getHotKeywords(authToken: token)
                async let allResponse = keywordsService.getAllKeywords(authToken: token)
                
                let (hot, all) = try await (hotResponse, allResponse)
                print("[Keywords] Loaded \(hot.count) hot keywords and \(all.count) total keywords")
                
                // Update all state at once
                hotKeywords = hot
                allKeywords = all
            } catch {
                print("[Keywords] Failed to load keywords: \(error)")
                hotKeywords = []
                allKeywords = []
            }
        }
        
        /// Search for articles using the current type and keyword
        @MainActor
        func performSearch(keyword: String) async {
            guard !keyword.isEmpty else { return }
            
            selectedKeyword = keyword
            print("[Search] Starting search with type: \(selectedType), keyword: \(keyword)")
            
            do {
                state = .loading
                let response = try await searchService.searchArticles(
                    type: selectedType,
                    bpTagId: keyword,
                    page: 1,
                    authToken: token
                )
                print("[Search] Found \(response.contents.data.count) articles")
                searchResults = response.contents.data
                state = .loaded
            } catch {
                print("[Search] Search failed: \(error)")
                state = .error(error)
                searchResults = []
            }
        }
        
        /// Update selected search type
        func selectType(_ type: SearchType) {
            selectedType = type
        }
    }
}
