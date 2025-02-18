import Foundation

@MainActor
final class KeywordSearchViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error(Error)
    }
    
    // MARK: - Published Properties
    @Published private(set) var state: ViewState = .loading
    @Published private(set) var hotKeywords: [KeywordModel] = []
    @Published private(set) var allKeywords: [KeywordModel] = []
    @Published private(set) var selectedHashtag: String?
    @Published private(set) var selectedType: Int?
    @Published private(set) var hasStartedSearch: Bool = false
    @Published private(set) var searchText: String = ""
    
    // MARK: - Dependencies
    private let service: EncyclopediaServiceProtocol
    private let token: String
    private let encyclopediaViewModel: EncyclopediaViewModel
    
    // MARK: - Constants
    let types = [1, 2, 3, 4]
    
    // MARK: - Initialization
    init(service: EncyclopediaServiceProtocol, token: String, encyclopediaViewModel: EncyclopediaViewModel) {
        self.service = service
        self.token = token
        self.encyclopediaViewModel = encyclopediaViewModel
        
        // Initialize with preloaded keywords if available
        if encyclopediaViewModel.keywordsLoaded {
            self.hotKeywords = encyclopediaViewModel.hotKeywords
            self.allKeywords = encyclopediaViewModel.allKeywords
            self.state = .loaded
        }
    }
    
    // MARK: - Public Methods
    func loadKeywords() async {
        // First try to use preloaded keywords
        if encyclopediaViewModel.keywordsLoaded {
            self.hotKeywords = encyclopediaViewModel.hotKeywords
            self.allKeywords = encyclopediaViewModel.allKeywords
            self.state = .loaded
            return
        }
        
        // Fall back to loading from API if needed
        state = .loading
        do {
            let keywords = try await service.getKeywords(authToken: token)
            self.hotKeywords = keywords.hot
            self.allKeywords = keywords.all
            self.state = .loaded
        } catch {
            self.state = .error(error)
        }
    }
    
    @MainActor
    func selectHashtag(_ hashtag: String) {
        print("[KeywordSearch] Selected hashtag: \(hashtag)")
        if selectedHashtag == hashtag {
            selectedHashtag = nil
            selectedType = nil
            hasStartedSearch = false
            encyclopediaViewModel.resetSearch()
            print("[KeywordSearch] Cleared selection")
        } else {
            selectedHashtag = hashtag
            if let type = selectedType, let keyword = (allKeywords + hotKeywords).first(where: { $0.bp_hashtag == hashtag }) {
                print("[KeywordSearch] Have both type (\(type)) and hashtag, performing search")
                hasStartedSearch = true
                Task {
                    await performSearch(type: type, keyword: keyword)
                }
            } else {
                print("[KeywordSearch] Waiting for type selection")
            }
        }
    }
    
    @MainActor
    func selectType(_ type: Int) {
        print("[KeywordSearch] Selected type: \(type)")
        if selectedType == type {
            selectedType = nil
            hasStartedSearch = false
            encyclopediaViewModel.resetSearch()
            print("[KeywordSearch] Cleared type selection")
        } else {
            selectedType = type
            if let hashtag = selectedHashtag, let keyword = (allKeywords + hotKeywords).first(where: { $0.bp_hashtag == hashtag }) {
                print("[KeywordSearch] Have both type and hashtag (\(hashtag)), performing search")
                hasStartedSearch = true
                Task {
                    await performSearch(type: type, keyword: keyword)
                }
            } else {
                print("[KeywordSearch] Waiting for hashtag selection")
            }
        }
    }
    
    func typeTitle(for type: Int) -> String {
        switch type {
        case 1: return "問題"
        case 2: return "原因"
        case 3: return "方法"
        case 4: return "建議"
        default: return ""
        }
    }
    
    @MainActor
    func performTextSearch(_ query: String) {
        print("[KeywordSearch] Starting text search with query: \(query)")
        searchText = query
        hasStartedSearch = true
        
        // First update UI to show we're searching
        encyclopediaViewModel.startSearch()
        
        // Perform the search
        Task {
            do {
                let articles = try await service.searchContent(query: query, authToken: token)
                print("[KeywordSearch] Text search response received:")
                print("  - Total articles: \(articles.count)")
                if !articles.isEmpty {
                    print("  - First article: \(articles[0].bp_subsection_title)")
                }
                
                // Update UI with results only if we're still in search mode
                // This prevents race conditions if user cancels search while request is in flight
                await MainActor.run {
                    if hasStartedSearch {
                        encyclopediaViewModel.updateSearchResults(articles)
                    } else {
                        print("[KeywordSearch] Search was cancelled, not updating results")
                    }
                }
            } catch {
                print("[KeywordSearch] Text search error: \(error)")
                await MainActor.run {
                    self.state = .error(error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func performSearch(type: Int, keyword: KeywordModel) async {
        do {
            print("[KeywordSearch] Starting search with:")
            print("  - Type: \(type)")
            print("  - Keyword tag_id: \(keyword.bp_tag_id)")
            print("  - Keyword hashtag: \(keyword.bp_hashtag)")
            
            // First update UI to show we're searching
            await MainActor.run {
                encyclopediaViewModel.startSearch()
            }
            
            // Perform the search with tag_id as Int
            let articles = try await service.searchContent(type: type, input: keyword.bp_tag_id, authToken: token)
            print("[KeywordSearch] Search response received:")
            print("  - Total articles: \(articles.count)")
            if !articles.isEmpty {
                print("  - First article: \(articles[0].bp_subsection_title)")
                print("  - First article type: \(articles[0].bp_subsection_type_type ?? 0)")
            }
            
            // Update UI with results only if we're still in search mode
            // This prevents race conditions if user cancels search while request is in flight
            await MainActor.run {
                if hasStartedSearch {
                    encyclopediaViewModel.updateSearchResults(articles)
                } else {
                    print("[KeywordSearch] Search was cancelled, not updating results")
                }
            }
        } catch {
            print("[KeywordSearch] Search error: \(error)")
            await MainActor.run {
                state = .error(error)
                encyclopediaViewModel.resetSearch()
                hasStartedSearch = false
            }
        }
    }
}
