#if canImport(SwiftUI) && os(iOS)
import Foundation
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
        public let details: [SkinAnalysis.Details]
        public let recommendations: [String]
        
        public init(
            score: Int,
            details: [SkinAnalysis.Details],
            recommendations: [String]
        ) {
            self.score = score
            self.details = details
            self.recommendations = recommendations
        }
    }
    
    // MARK: - Analysis Results Details
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
            SkinAnalysis.Details(
                category: "膚質",
                score: 90,
                description: "皮膚質地良好，保養得宜"
            ),
            SkinAnalysis.Details(
                category: "色調",
                score: 80,
                description: "膚色均勻，光澤自然"
            )
        ],
        recommendations: [
            "保持良好的保養習慣",
            "注意防曬，避免色素沉澱"
        ]
    )
}
#endif
