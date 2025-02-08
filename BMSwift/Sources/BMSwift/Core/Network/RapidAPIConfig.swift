#if canImport(UIKit) && os(iOS)
import Foundation

/// Configuration for RapidAPI services
public enum RapidAPIConfig {
    /// Face analysis API configuration
    public static let faceAnalysis = BMNetwork.Configuration(
        baseURL: URL(string: "https://face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com")!,
        defaultHeaders: [
            "x-rapidapi-key": "0fc47de525mshb9e37b660469c06p1c82b4jsnc54f0234e207",
            "x-rapidapi-host": "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com",
            "Content-Type": "application/x-www-form-urlencoded"
        ],
        timeoutInterval: 30,
        cachePolicy: .useProtocolCachePolicy
    )
}

#endif
