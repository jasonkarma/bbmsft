import Foundation

public struct Configuration {
    /// Base URL for the API endpoints
    public let baseURL: URL
    
    /// Default headers to be included in all requests
    public let defaultHeaders: [String: String]
    
    /// Creates a new Configuration instance
    /// - Parameters:
    ///   - baseURL: Base URL for API endpoints
    ///   - defaultHeaders: Default headers for all requests
    public init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
    
    /// Default production configuration
    public static var production: Configuration {
        Configuration(
            baseURL: URL(string: "https://wiki.kinglyrobot.com")!,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
    }
    
    /// Default development configuration
    public static var development: Configuration {
        Configuration(
            baseURL: URL(string: "https://dev.wiki.kinglyrobot.com")!,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
    }
}
