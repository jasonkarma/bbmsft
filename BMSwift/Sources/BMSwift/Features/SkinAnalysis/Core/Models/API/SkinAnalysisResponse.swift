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
                category: "面部结构",
                score: Int(result.photoAnalysis.facialFeatures.overallStructure.balanceScore * 100),
                description: result.photoAnalysis.facialFeatures.overallStructure.description
            ),
            SkinAnalysis.Details(
                category: "肤质",
                score: Int(result.photoAnalysis.facialFeatures.skinQuality.clarityScore * 100),
                description: result.photoAnalysis.facialFeatures.skinQuality.description
            ),
            SkinAnalysis.Details(
                category: "眼部",
                score: Int(result.photoAnalysis.facialFeatures.eyeArea.harmonyScore * 100),
                description: result.photoAnalysis.facialFeatures.eyeArea.description
            ),
            SkinAnalysis.Details(
                category: "嘴部",
                score: Int(result.photoAnalysis.facialFeatures.mouthArea.proportionScore * 100),
                description: result.photoAnalysis.facialFeatures.mouthArea.description
            ),
            SkinAnalysis.Details(
                category: "鼻部",
                score: Int(result.photoAnalysis.facialFeatures.noseArea.balanceScore * 100),
                description: result.photoAnalysis.facialFeatures.noseArea.description
            ),
            SkinAnalysis.Details(
                category: "面颊",
                score: Int(result.photoAnalysis.facialFeatures.cheekArea.contourScore * 100),
                description: result.photoAnalysis.facialFeatures.cheekArea.description
            ),
            SkinAnalysis.Details(
                category: "下颌",
                score: Int(result.photoAnalysis.facialFeatures.jawArea.definitionScore * 100),
                description: result.photoAnalysis.facialFeatures.jawArea.description
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
    public let facialFeatures: FacialFeatures
    public let overallScore: Double
    public let recommendations: [String]
    
    private enum CodingKeys: String, CodingKey {
        case facialFeatures = "facial_features"
        case overallScore = "overall_score"
        case recommendations
    }
}

// MARK: - Facial Features
public struct FacialFeatures: Codable {
    public let overallStructure: FeatureDetail
    public let skinQuality: FeatureDetail
    public let eyeArea: FeatureDetail
    public let mouthArea: FeatureDetail
    public let noseArea: FeatureDetail
    public let cheekArea: FeatureDetail
    public let jawArea: FeatureDetail
    
    private enum CodingKeys: String, CodingKey {
        case overallStructure = "overall_structure"
        case skinQuality = "skin_quality"
        case eyeArea = "eye_area"
        case mouthArea = "mouth_area"
        case noseArea = "nose_area"
        case cheekArea = "cheek_area"
        case jawArea = "jaw_area"
    }
}

// MARK: - Feature Detail
public struct FeatureDetail: Codable {
    public let balanceScore: Double
    public let clarityScore: Double
    public let harmonyScore: Double
    public let proportionScore: Double
    public let contourScore: Double
    public let definitionScore: Double
    public let description: String
    
    private enum CodingKeys: String, CodingKey {
        case balanceScore = "balance_score"
        case clarityScore = "clarity_score"
        case harmonyScore = "harmony_score"
        case proportionScore = "proportion_score"
        case contourScore = "contour_score"
        case definitionScore = "definition_score"
        case description
    }
}

#endif
