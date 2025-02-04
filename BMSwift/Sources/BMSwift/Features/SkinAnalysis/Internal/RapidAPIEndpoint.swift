import Foundation

enum SkinAnalysisEndpoints {
    // MARK: - Configuration
    static let rapidAPIConfig = BMNetwork.Configuration(
        baseURL: URL(string: "https://face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com")!,
        defaultHeaders: [
            "x-rapidapi-key": "0fc47de525mshb9e37b660469c06p1c82b4jsnc54f0234e207",
            "x-rapidapi-host": "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    )
    
    // MARK: - Analyze Endpoint
    struct AnalyzeEndpoint: BMNetwork.APIEndpoint {
        typealias RequestType = EmptyRequest
        typealias ResponseType = SkinAnalysisResponse
        
        let imageUrl: String
        let language: String
        
        var path: String { "/check" }
        var method: BMNetwork.HTTPMethod { .post }
        var baseURL: URL? { SkinAnalysisEndpoints.rapidAPIConfig.baseURL }
        var headers: [String: String] { SkinAnalysisEndpoints.rapidAPIConfig.defaultHeaders }
        
        var queryItems: [URLQueryItem] {
            [
                URLQueryItem(name: "imageUrl", value: imageUrl),
                URLQueryItem(name: "lang", value: language)
            ]
        }
        
        init(imageUrl: String, language: String = "en") {
            self.imageUrl = imageUrl
            self.language = language
        }
    }
    
    struct EmptyRequest: Encodable {}
}
