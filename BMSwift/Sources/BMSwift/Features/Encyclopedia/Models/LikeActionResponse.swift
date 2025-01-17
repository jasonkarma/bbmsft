import Foundation

public struct LikeActionResponse: Codable {
    public let likeAction: Bool
    
    private enum CodingKeys: String, CodingKey {
        case likeAction = "LikeAction"
    }
}
