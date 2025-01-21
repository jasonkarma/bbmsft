#if canImport(SwiftUI) && os(iOS)
import UIKit

// MARK: - Analysis Service Protocol
@available(iOS 13.0, *)
public protocol AnalysisService: Sendable {
    func analyze(image: UIImage) async throws -> SkinAnalysis.AnalysisResults
}

// MARK: - Analysis Results
public enum SkinAnalysis {
    public struct AnalysisResults {
        public let score: Int
        public let details: [Details]
        public let recommendations: [String]
        
        public init(
            score: Int,
            details: [Details],
            recommendations: [String]
        ) {
            self.score = score
            self.details = details
            self.recommendations = recommendations
        }
    }
    
    public struct Details {
        public let category: String
        public let score: Int
        public let description: String
        
        public init(
            category: String,
            score: Int,
            description: String
        ) {
            self.category = category
            self.score = score
            self.description = description
        }
    }
}

// MARK: - Mock Data
public extension SkinAnalysis.AnalysisResults {
    static let mock = SkinAnalysis.AnalysisResults(
        score: 85,
        details: [
            .init(category: "Overall", score: 85, description: "Good overall facial features"),
            .init(category: "Face Structure", score: 90, description: "Well-balanced facial structure"),
            .init(category: "Eyes", score: 88, description: "Symmetrical eye placement"),
            .init(category: "Nose", score: 82, description: "Proportionate nose shape"),
            .init(category: "Mouth", score: 87, description: "Good lip shape and symmetry"),
            .init(category: "Skin", score: 83, description: "Healthy skin texture")
        ],
        recommendations: [
            "Consider using sunscreen daily",
            "Stay hydrated for better skin health",
            "Maintain a consistent skincare routine"
        ]
    )
}
#endif
