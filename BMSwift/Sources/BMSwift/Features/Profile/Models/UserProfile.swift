import Foundation

public struct ProfileResponse: Codable {
    public let user: User
    public let permission: [Permission]
    public let sport: Sport
}

public struct User: Codable {
    public let realname: String?
    public let phone: String?
    public let city: String?
    public let birth: String?
    public let height: Int?
    public let weight: Int?
    public let sex: Int?
    public let username: String
    public let email: String
    public let id: Int
    public let bloodType: Int?
    public let mediaName: String?
    
    private enum CodingKeys: String, CodingKey {
        case realname, phone, city, birth, height, weight, sex, username, email, id
        case bloodType = "blood_type"
        case mediaName = "media_name"
    }
    
    public var sexString: String {
        switch sex {
        case 0: return "女"
        case 1: return "男"
        case 2: return "不公開"
        default: return "不公開"
        }
    }
    
    public var bloodTypeString: String {
        switch bloodType {
        case 0: return "A"
        case 1: return "B"
        case 2: return "AB"
        case 3: return "O"
        default: return "-"
        }
    }
}

public struct Permission: Codable {
    public let userId: Int
    public let platform: Int
    public let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case platform
        case createdAt = "created_at"
    }
}

public struct Sport: Codable {
    public let questionnaire: String
}
