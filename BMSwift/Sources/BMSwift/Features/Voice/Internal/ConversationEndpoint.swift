import Foundation

extension VoiceEndpoints {
    /// Endpoint for getting conversation responses
    public struct Conversation: BMNetwork.APIEndpoint {
        public typealias RequestType = EmptyRequest?
        public typealias ResponseType = ConversationResponse
        
        public var baseURL: URL? { URL(string: "https://gptbot.kinglyrobot.com") }
        public let path: String = "/api/qa"
        public let method: BMNetwork.HTTPMethod = .get
        public let requiresAuth: Bool = false
        public let headers: [String: String] = [:]
        
        public var queryItems: [URLQueryItem]? {
            [
                URLQueryItem(name: "name", value: "KinglyAI"),
                URLQueryItem(name: "id", value: text)
            ]
        }
        
        private let text: String
        
        public init(text: String) {
            self.text = text
        }
    }
}
