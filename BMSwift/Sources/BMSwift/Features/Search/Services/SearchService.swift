import Foundation

public protocol SearchServiceProtocol {
    /// Search for articles by hashtag and type
    /// - Parameters:
    ///   - tagId: The hashtag ID to search for
    ///   - type: Content type (1: 問題, 2: 原因, 3: 方法, 4: 建議)
    ///   - page: Page number to fetch
    ///   - authToken: Authentication token
    /// - Returns: SearchResponse containing matching articles
    func searchContent(tagId: Int, type: Int, page: Int, authToken: String) async throws -> Search.SearchResponse
    
    /// Search content using voice input
    /// - Parameters:
    ///   - voiceText: Transcribed voice text
    ///   - type: Content type (0 for all, 1: 問題, 2: 原因, 3: 方法, 4: 建議)
    ///   - page: Page number to fetch
    ///   - authToken: Authentication token
    /// - Returns: VoiceSearchResponse containing matching articles
    func searchByVoice(voiceText: String, type: Int, page: Int, authToken: String) async throws -> VoiceSearch.SearchResponse
}

    final class SearchService: SearchServiceProtocol {
        // MARK: - Properties
        private let client: BMNetwork.NetworkClient
        
        // MARK: - Initialization
        public init(client: BMNetwork.NetworkClient) {
            self.client = client
        }
        
        // MARK: - SearchServiceProtocol
        func searchContent(tagId: Int, type: Int, page: Int, authToken: String) async throws -> Search.SearchResponse {
            print("[SearchService] Searching with tagId: \(tagId), type: \(type), page: \(page)")
            let request = BMNetwork.APIRequest<SearchEndpoints.ContentSearch>(
                endpoint: SearchEndpoints.ContentSearch(
                    tagId: tagId,
                    type: type,
                    page: page,
                    authToken: authToken
                ),
                authToken: authToken
            )
            
            do {
                print("[SearchService] Sending request...")
                let response = try await client.send(request)
                print("[SearchService] Got response with \(response.contents.data.count) results")
                return response
            } catch {
                print("[SearchService] Error: \(error)")
                throw error
            }
        }
        
        func searchByVoice(voiceText: String, type: Int, page: Int, authToken: String) async throws -> VoiceSearch.SearchResponse {
            print("[SearchService] Voice searching with text: \(voiceText), type: \(type), page: \(page)")
            let endpoint = VoiceEndpoints.ContentHashtag(searchText: voiceText, type: type, page: page, authToken: authToken)
            let request = BMNetwork.APIRequest(endpoint: endpoint, authToken: authToken)
            
            do {
                print("[SearchService] Sending voice search request...")
                let response = try await client.send(request)
                print("[SearchService] Got voice search response with \(response.contents.data.count) results")
                
                return VoiceSearch.SearchResponse(
                    normalSuggestion: true,
                    contents: response.contents
                )
            } catch {
                print("[SearchService] Voice search error: \(error)")
                throw error
            }
        }
    }
