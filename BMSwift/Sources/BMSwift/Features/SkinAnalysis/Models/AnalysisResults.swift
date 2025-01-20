#if canImport(SwiftUI) && os(iOS)
import Foundation

@available(iOS 13.0, *)
public struct AnalysisResults: Codable {
    public let score: Int
    public let details: [Detail]
    public let recommendations: [String]
    
    public init(score: Int, details: [Detail], recommendations: [String]) {
        self.score = score
        self.details = details
        self.recommendations = recommendations
    }
    
    public struct Detail: Codable {
        public let category: String
        public let score: Int
        
        public init(category: String, score: Int) {
            self.category = category
            self.score = score
        }
    }
}
#endif
