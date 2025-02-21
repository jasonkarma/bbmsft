import Foundation

protocol VoiceSearchServiceProtocol {
    func searchByVoice(voiceText: String, type: Int, page: Int, authToken: String) async throws -> VoiceSearch.SearchResponse
}

final class VoiceSearchService: VoiceSearchServiceProtocol {
    private let client: BMNetwork.NetworkClient
    
    init(client: BMNetwork.NetworkClient = .shared) {
        self.client = client
    }
    
    /// Search content using voice text
    /// First gets keyword from KNN API, then uses that to search content
    func searchByVoice(voiceText: String, type: Int, page: Int, authToken: String) async throws -> VoiceSearch.SearchResponse {
        print("DEBUG: Starting voice search with text: \(voiceText)")
        
        // First call KNN API to get search ID
        let knnRequest = BMNetwork.APIRequest<VoiceEndpoints.KNNSearch>(endpoint: VoiceEndpoints.KNNSearch(voiceText: voiceText))
        let knnResponse = try await client.send(knnRequest)
        print("DEBUG: KNN response: \(knnResponse)")
        
        // Check confidence threshold
        if knnResponse.confidence < 0.7 {
            print("DEBUG: Low confidence score \(knnResponse.confidence), returning no results")
            // Return empty response for low confidence
            return VoiceSearch.SearchResponse(
                normalSuggestion: false,
                contents: .init(
                    currentPage: page,
                    data: [],
                    firstPageUrl: "",
                    from: 0,
                    lastPage: page,
                    lastPageUrl: "",
                    links: [],
                    nextPageUrl: nil,
                    path: "",
                    perPage: 10,
                    prevPageUrl: nil,
                    to: 0,
                    total: 0
                )
            )
        }
        
        // Extract keyword using KNNResponse's property
        guard let keyword = knnResponse.extractedKeyword else {
            print("DEBUG: Could not extract keyword after 'api' from: \(knnResponse.text)")
            return VoiceSearch.SearchResponse(
                normalSuggestion: false,
                contents: .init(
                    currentPage: page,
                    data: [],
                    firstPageUrl: "",
                    from: 0,
                    lastPage: page,
                    lastPageUrl: "",
                    links: [],
                    nextPageUrl: nil,
                    path: "",
                    perPage: 10,
                    prevPageUrl: nil,
                    to: 0,
                    total: 0
                )
            )
        }
        
        print("DEBUG: Extracted keyword: \(keyword)")
        
        // Use the extracted keyword to search content
        let endpoint = VoiceEndpoints.ContentHashtag(searchText: keyword, type: type, page: page, authToken: authToken)
        let request = BMNetwork.APIRequest(endpoint: endpoint, authToken: authToken)
        let response = try await client.send(request)
        
        return VoiceSearch.SearchResponse(
            normalSuggestion: true,
            contents: response.contents
        )
    }
}
