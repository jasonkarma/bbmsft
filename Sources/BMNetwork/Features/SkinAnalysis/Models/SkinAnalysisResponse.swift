#if canImport(SwiftUI) && os(iOS)
import Foundation

// MARK: - API Response
public struct SkinAnalysisResponse: Codable {
    public let result: AnalysisResult
    public let cacheTime: Int
    public let status: String
    public let message: String
    public let time: Int
    
    private enum CodingKeys: String, CodingKey {
        case result
        case cacheTime = "cache_time"
        case status
        case message
        case time
    }
    
    public func toDomain() -> SkinAnalysis.AnalysisResults {
        let details = [
            SkinAnalysis.Details(
                category: "Overall",
                score: Int(result.photoAnalysis.overallScore * 100),
                description: result.photoAnalysis.overallDescription
            ),
            SkinAnalysis.Details(
                category: "Face Structure",
                score: Int(result.photoAnalysis.faceStructure.score * 100),
                description: result.photoAnalysis.faceStructure.description
            ),
            SkinAnalysis.Details(
                category: "Eyes",
                score: Int(result.photoAnalysis.eyeArea.score * 100),
                description: result.photoAnalysis.eyeArea.description
            ),
            SkinAnalysis.Details(
                category: "Nose",
                score: Int(result.photoAnalysis.noseArea.score * 100),
                description: result.photoAnalysis.noseArea.description
            ),
            SkinAnalysis.Details(
                category: "Mouth",
                score: Int(result.photoAnalysis.mouthArea.score * 100),
                description: result.photoAnalysis.mouthArea.description
            ),
            SkinAnalysis.Details(
                category: "Skin",
                score: Int(result.photoAnalysis.skinQuality.score * 100),
                description: result.photoAnalysis.skinQuality.description
            )
        ]
        
        return SkinAnalysis.AnalysisResults(
            score: Int(result.photoAnalysis.overallScore * 100),
            details: details,
            recommendations: result.photoAnalysis.recommendations
        )
    }
}

// MARK: - Analysis Result
public struct AnalysisResult: Codable {
    public let photoAnalysis: PhotoAnalysis
    
    private enum CodingKeys: String, CodingKey {
        case photoAnalysis = "photo_analysis"
    }
}

// MARK: - Photo Analysis
public struct PhotoAnalysis: Codable {
    public let overallScore: Double
    public let overallDescription: String
    public let faceStructure: FeatureAnalysis
    public let eyeArea: FeatureAnalysis
    public let noseArea: FeatureAnalysis
    public let mouthArea: FeatureAnalysis
    public let skinQuality: FeatureAnalysis
    public let recommendations: [String]
    
    private enum CodingKeys: String, CodingKey {
        case overallScore = "overall_score"
        case overallDescription = "overall_description"
        case faceStructure = "face_structure"
        case eyeArea = "eye_area"
        case noseArea = "nose_area"
        case mouthArea = "mouth_area"
        case skinQuality = "skin_quality"
        case recommendations
    }
}

// MARK: - Feature Analysis
public struct FeatureAnalysis: Codable {
    public let score: Double
    public let description: String
}
#endif
