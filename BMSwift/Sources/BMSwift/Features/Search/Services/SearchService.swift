import Foundation

public protocol SearchServiceProtocol {
        /// Search for articles by hashtag and type
        /// - Parameters:
        ///   - tagId: The hashtag ID to search for
        ///   - type: Content type (1: 問題, 2: 原因, 3: 方法, 4: 建議)
        ///   - authToken: Authentication token
        /// - Returns: SearchResponse containing matching articles
        func searchContent(tagId: Int, type: Int, authToken: String) async throws -> Search.SearchResponse
}

    final class SearchService: SearchServiceProtocol {
        // MARK: - Properties
        private let client: BMNetwork.NetworkClient
        
        // MARK: - Initialization
        public init(client: BMNetwork.NetworkClient) {
            self.client = client
        }
        
        // MARK: - SearchServiceProtocol
        func searchContent(tagId: Int, type: Int, authToken: String) async throws -> Search.SearchResponse {
            print("[SearchService] Searching with tagId: \(tagId), type: \(type)")
            let request = SearchEndpoints.contentSearch(tagId: tagId, type: type, authToken: authToken)
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
    }
