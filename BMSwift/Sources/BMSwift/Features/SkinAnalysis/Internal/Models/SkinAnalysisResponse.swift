#if canImport(UIKit) && os(iOS)
import Foundation

public struct SkinAnalysisResponse: Codable {
    public let overallScore: Double
    public let detailedScores: [DetailedScore]
    public let recommendations: [String]
    
    public init(overallScore: Double, detailedScores: [DetailedScore], recommendations: [String]) {
        self.overallScore = overallScore
        self.detailedScores = detailedScores
        self.recommendations = recommendations
    }
    
    public init(from rapidAPIResponse: RapidAPI.Response) {
        let analysis = rapidAPIResponse.result.photoAnalysis
        let impression = rapidAPIResponse.result.overallImpression
        
        self.overallScore = impression.overallScore
        
        // Convert API scores to DetailedScore array
        self.detailedScores = [
            DetailedScore(category: "構圖", score: analysis.composition.compositionScore),
            DetailedScore(category: "光線", score: analysis.lighting.lightingScore),
            DetailedScore(category: "色彩", score: analysis.color.colorScore),
            DetailedScore(category: "清晰度", score: analysis.technicalQuality.qualityScore),
            DetailedScore(category: "膚質", score: analysis.facialFeatures.skinQuality.score),
            DetailedScore(category: "五官平衡", score: analysis.facialFeatures.overallStructure.score)
        ]
        
        self.recommendations = impression.suggestions
    }
}

public struct DetailedScore: Codable, Identifiable {
    public let id: UUID
    public let category: String
    public let score: Double
    
    public init(id: UUID = UUID(), category: String, score: Double) {
        self.id = id
        self.category = category
        self.score = score
    }
}

#if DEBUG
extension SkinAnalysisResponse {
    public static var preview: SkinAnalysisResponse {
        SkinAnalysisResponse(
            overallScore: 85.0,
            detailedScores: [
                DetailedScore(category: "構圖", score: 88.0),
                DetailedScore(category: "光線", score: 85.0),
                DetailedScore(category: "色彩", score: 87.0),
                DetailedScore(category: "清晰度", score: 90.0),
                DetailedScore(category: "膚質", score: 82.0),
                DetailedScore(category: "五官平衡", score: 84.0)
            ],
            recommendations: [
                "調整光線以提升膚質表現",
                "可以嘗試不同角度以突顯輪廓",
                "建議使用補光以減少陰影"
            ]
        )
    }
}
#endif
#endif