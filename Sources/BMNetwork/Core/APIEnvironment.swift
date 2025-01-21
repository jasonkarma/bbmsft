import Foundation

/// Defines different API environments
public enum APIEnvironment {
    case encyclopedia
    case skinAnalysis
    case custom(URL)
    
    var baseURL: URL {
        switch self {
        case .encyclopedia:
            return URL(string: "https://wiki.kinglyrobot.com")!
        case .skinAnalysis:
            return URL(string: "https://skin-analysis.api.example.com")! // Replace with actual skin analysis API URL
        case .custom(let url):
            return url
        }
    }
}
