#if canImport(UIKit) && os(iOS)
import Foundation

public enum ImgurConfig {
    public static let clientId = "ef3ec7ca514d8d5"
    public static let clientSecret = "5d864f343c54e1cb6db01c25f5241690f50a62bc"
    public static let accessToken = "68de8aa7d34e7407ef2753ceaa412f13b4d50b6e"
    public static let refreshToken = "e5c7d454f2c0c9c9d2e9d6a6f8b7a3e2d1c0b9a8"
    public static let baseURL = "https://api.imgur.com/3"
    public static let authURL = "https://api.imgur.com/oauth2/token"
    
    public static var headers: [String: String] {
        ["Authorization": "Bearer \(accessToken)"]
    }
}
#endif
