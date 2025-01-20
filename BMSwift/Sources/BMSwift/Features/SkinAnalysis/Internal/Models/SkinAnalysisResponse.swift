import Foundation

struct SkinAnalysisResponse: Codable {
    let result: AnalysisResult
    let cacheTime: Int
    let status: String
    let message: String
    let time: Int
}

struct AnalysisResult: Codable {
    let photoAnalysis: PhotoAnalysis
    let overallImpression: OverallImpression
    
    enum CodingKeys: String, CodingKey {
        case photoAnalysis = "photo_analysis"
        case overallImpression = "overall_impression"
    }
}

struct PhotoAnalysis: Codable {
    let composition: Composition
    let lighting: Lighting
    let color: Color
    let technicalQuality: TechnicalQuality
    let facialFeatures: FacialFeatures
    
    enum CodingKeys: String, CodingKey {
        case composition, lighting, color
        case technicalQuality = "technical_quality"
        case facialFeatures = "facial_features"
    }
}

struct Composition: Codable {
    let description: String
    let notableElements: [String]
    let compositionScore: Int
    
    enum CodingKeys: String, CodingKey {
        case description
        case notableElements = "notable_elements"
        case compositionScore = "composition_score"
    }
}

struct Lighting: Codable {
    let description: String
    let notableElements: [String]
    let lightingScore: Int
    
    enum CodingKeys: String, CodingKey {
        case description
        case notableElements = "notable_elements"
        case lightingScore = "lighting_score"
    }
}

struct Color: Codable {
    let palette: String
    let notableElements: [String]
    let colorScore: Int
    
    enum CodingKeys: String, CodingKey {
        case palette
        case notableElements = "notable_elements"
        case colorScore = "color_score"
    }
}

struct TechnicalQuality: Codable {
    let sharpness: String
    let exposure: String
    let depthOfField: String
    let qualityScore: Int
    
    enum CodingKeys: String, CodingKey {
        case sharpness, exposure
        case depthOfField = "depth_of_field"
        case qualityScore = "quality_score"
    }
}

struct FacialFeatures: Codable {
    let overallStructure: FeatureDetail
    let skinQuality: FeatureDetail
    let eyeArea: FeatureDetail
    let mouthArea: FeatureDetail
    let noseArea: FeatureDetail
    let cheekArea: FeatureDetail
    let jawArea: FeatureDetail
    
    enum CodingKeys: String, CodingKey {
        case overallStructure = "overall_structure"
        case skinQuality = "skin_quality"
        case eyeArea = "eye_area"
        case mouthArea = "mouth_area"
        case noseArea = "nose_area"
        case cheekArea = "cheek_area"
        case jawArea = "jaw_area"
    }
}

struct FeatureDetail: Codable {
    let description: String
    let score: Int
    
    enum CodingKeys: String, CodingKey {
        case description
        case score = "balance_score" // Note: Different features use different score names but same structure
    }
}

struct OverallImpression: Codable {
    let mood: String
    let uniqueElements: [String]
    let overallScore: Int
    let suggestions: [String]
    
    enum CodingKeys: String, CodingKey {
        case mood
        case uniqueElements = "unique_elements"
        case overallScore = "overall_score"
        case suggestions
    }
}