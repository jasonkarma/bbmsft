import Foundation

/// Response from conversation API containing question and answer
public struct ConversationResponse: Codable {
    public let q: String
    public let ans: String
    
    public init(q: String, ans: String) {
        self.q = q
        self.ans = ans
    }
}
