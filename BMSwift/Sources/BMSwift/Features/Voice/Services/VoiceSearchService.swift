import Foundation

protocol VoiceSearchServiceProtocol {
    func searchByVoice(voiceText: String) async throws -> VoiceEndpoints.SearchResponse
}

final class VoiceSearchService: VoiceSearchServiceProtocol {
    private let client: BMNetwork.NetworkClient
    
    init(client: BMNetwork.NetworkClient = .shared) {
        self.client = client
    }
    
    /// Search content using voice text
    /// First gets keyword from KNN API, then uses that to search content
    func searchByVoice(voiceText: String) async throws -> VoiceEndpoints.SearchResponse {
        print("DEBUG: Starting voice search with text: \(voiceText)")
        
        // First call KNN API to get search ID
        let knnRequest = BMNetwork.APIRequest<VoiceEndpoints.KNNSearch>(endpoint: VoiceEndpoints.KNNSearch(voiceText: voiceText))
        let knnResponse = try await client.send(knnRequest)
        print("DEBUG: KNN response: \(knnResponse)")
        
        // Check confidence threshold
        if knnResponse.confidence < 0.7 {
            print("DEBUG: Low confidence score \(knnResponse.confidence), returning no results")
            // Return empty response for low confidence
            return VoiceEndpoints.SearchResponse(contents: .init(data: []))
        }
        
        // Extract keyword after 'api'
        guard let keyword = knnResponse.text.range(of: "api").map({ String(knnResponse.text[knnResponse.text.index(after: $0.upperBound)...]) }) else {
            print("DEBUG: Could not extract keyword after 'api' from: \(knnResponse.text)")
            return VoiceEndpoints.SearchResponse(contents: .init(data: []))
        }
        
        print("DEBUG: Extracted keyword: \(keyword)")
        
        // Use the extracted keyword to search content
        let contentRequest = BMNetwork.APIRequest<VoiceEndpoints.ContentHashtag>(endpoint: VoiceEndpoints.ContentHashtag(searchText: keyword))
        return try await client.send(contentRequest)
    }
}
