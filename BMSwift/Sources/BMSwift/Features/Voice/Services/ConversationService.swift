import Foundation

public protocol ConversationServiceProtocol {
    func getResponse(for text: String) async throws -> ConversationResponse
}

public final class ConversationService: ConversationServiceProtocol {
    private let client: BMNetwork.NetworkClient
    
    public init(client: BMNetwork.NetworkClient = .shared) {
        self.client = client
    }
    
    public func getResponse(for text: String) async throws -> ConversationResponse {
        let request = BMNetwork.APIRequest<VoiceEndpoints.Conversation>(endpoint: .init(text: text))
        return try await client.send(request)
    }
}
