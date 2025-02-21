import Foundation

@MainActor
@dynamicMemberLookup
final class KeywordSearchViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Pagination State
    private var currentPage = 1  // Start at page 1 to match API
    private var lastPage = 1
    
    public var canLoadMore: Bool {
        currentPage < lastPage && !isLoading && !searchResults.isEmpty
    }
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
    
    private func setupNotificationObserver() {
        // Observe load more notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoadMore), name: .loadMoreResults, object: nil)
    }
    
    init(
        encyclopediaViewModel: EncyclopediaViewModel,
        token: String,
        encyclopediaService: EncyclopediaServiceProtocol = EncyclopediaService(client: .shared),
        searchService: SearchServiceProtocol = SearchService(client: .shared)
    ) {
        self.encyclopediaViewModel = encyclopediaViewModel
        self.token = token
        self.encyclopediaService = encyclopediaService
        self.searchService = searchService
        setupNotificationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleLoadMore(_ notification: Notification) {
        // Extract source from notification
        let source = notification.userInfo?["source"] as? EncyclopediaViewModel.SearchSource
        
        // Only proceed if this is a keyword search notification
        guard source == .keyword else {
            print("[KeywordSearch] Skipping notification: source=\(source?.description ?? "none")")
            return
        }
        
        // Check if we can load more
        guard !isLoading && currentPage < lastPage else {
            print("[KeywordSearch] Cannot load more: page=\(currentPage)/\(lastPage), isLoading=\(isLoading)")
            return
        }
        
        // Handle the load more request
        print("[KeywordSearch] Loading more results (page \(currentPage + 1))")
        Task {
            await performSearch(loadMore: true)
        }
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
    
    func performSearch(loadMore: Bool = false) async {
        guard let hashtag = selectedHashtag,
              let type = selectedType,
              let keyword = allKeywords.first(where: { $0.bp_hashtag == hashtag }) else {
            print("[KeywordSearch] Cannot search: hashtag=\(selectedHashtag ?? "nil"), type=\(selectedType ?? -1)")
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing search parameters"])
            return
        }
        
        // Thread-safe state update
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        // Only reset pagination for new searches
        if !loadMore {
            print("[KeywordSearch] New search - resetting pagination")
            currentPage = 1
            lastPage = 1
            encyclopediaViewModel.clearSearchResults()
            encyclopediaViewModel.updateSearchSource(.keyword)
        }
        
        let nextPage = loadMore ? currentPage + 1 : 1
        print("[KeywordSearch] Requesting page \(nextPage) with tagId=\(keyword.bp_tag_id)")
        
        do {
            let response = try await searchService.searchContent(
                tagId: keyword.bp_tag_id,
                type: type,
                page: nextPage,
                authToken: token
            )
            
            await MainActor.run {
                // Update pagination state
                currentPage = response.contents.currentPage
                lastPage = response.contents.lastPage
                
                // Update encyclopedia view model with search results
                print("[KeywordSearchViewModel] Search successful with \(response.contents.data.count) results")
                encyclopediaViewModel.updateWithSearchResults(
                    response.contents.data,
                    page: response.contents.currentPage,
                    lastPage: response.contents.lastPage,
                    append: loadMore,
                    totalArticles: response.contents.total
                )
                
                // Update local state
                if loadMore {
                    self.searchResults.append(contentsOf: response.contents.data)
                } else {
                    self.searchResults = response.contents.data
                }
                
                state = .loaded
                isLoading = false
                error = nil
            }
        } catch {
            print("[KeywordSearchViewModel] Search failed: \(error)")
            await MainActor.run {
                state = .error(error)
                isLoading = false
                self.error = error
            }
        }
    }

    
    subscript<T>(dynamicMember keyPath: KeyPath<KeywordSearchViewModel, T>) -> T {
        self[keyPath: keyPath]
    }
}
