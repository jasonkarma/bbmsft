#if canImport(UIKit) && os(iOS)
import Foundation

/// Models for the Skin Analysis feature
public enum SkinAnalysisModels {
    // MARK: - Request Types
    public struct AnalyzeRequest: Codable, Equatable {
        public let base64Image: String
        
        private enum CodingKeys: String, CodingKey {
            case base64Image = "image_data"
        }
        
        public init(base64Image: String) {
            self.base64Image = base64Image
        }
    }
    
    // MARK: - Response Types
    public struct Response: Codable, Equatable {
        public let result: Result
        public let status: String
        public let message: String
        public let time: TimeInterval
        public let cacheTime: TimeInterval
        
        private enum CodingKeys: String, CodingKey {
            case result
            case status
            case message
            case time
            case cacheTime
        }
    }
    
    public struct Result: Codable, Equatable {
        public let photoAnalysis: PhotoAnalysis
        public let overallImpression: OverallImpression
        
        private enum CodingKeys: String, CodingKey {
            case photoAnalysis = "photo_analysis"
            case overallImpression = "overall_impression"
        }
    }
    
    public struct PhotoAnalysis: Codable, Equatable {
        public let composition: Composition
        public let lighting: Lighting
        public let color: Color
        public let technicalQuality: TechnicalQuality
        public let facialFeatures: FacialFeatures
        
        private enum CodingKeys: String, CodingKey {
            case composition
            case lighting
            case color
            case technicalQuality = "technical_quality"
            case facialFeatures = "facial_features"
        }
    }
    
    public struct Composition: Codable, Equatable {
        public let description: String
        public let notableElements: [String]
        public let compositionScore: Int
        
        private enum CodingKeys: String, CodingKey {
            case description
            case notableElements = "notable_elements"
            case compositionScore = "composition_score"
        }
    }
    
    public struct Lighting: Codable, Equatable {
        public let description: String
        public let notableElements: [String]
        public let lightingScore: Int
        
        private enum CodingKeys: String, CodingKey {
            case description
            case notableElements = "notable_elements"
            case lightingScore = "lighting_score"
        }
    }
    
    public struct Color: Codable, Equatable {
        public let palette: String
        public let notableElements: [String]
        public let colorScore: Int
        
        private enum CodingKeys: String, CodingKey {
            case palette
            case notableElements = "notable_elements"
            case colorScore = "color_score"
        }
    }
    
    public struct TechnicalQuality: Codable, Equatable {
        public let sharpness: String
        public let exposure: String
        public let depthOfField: String
        public let qualityScore: Int
        
        private enum CodingKeys: String, CodingKey {
            case sharpness
            case exposure
            case depthOfField = "depth_of_field"
            case qualityScore = "quality_score"
        }
    }
    
    public struct FacialFeatures: Codable, Equatable {
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
    
    public struct FeatureDetail: Codable, Equatable {
        public let description: String
        public var balanceScore: Int?
        public var clarityScore: Int?
        public var harmonyScore: Int?
        public var proportionScore: Int?
        public var contourScore: Int?
        public var definitionScore: Int?
        
        private enum CodingKeys: String, CodingKey {
            case description
            case balanceScore = "balance_score"
            case clarityScore = "clarity_score"
            case harmonyScore = "harmony_score"
            case proportionScore = "proportion_score"
            case contourScore = "contour_score"
            case definitionScore = "definition_score"
        }
    }
    
    public struct OverallImpression: Codable, Equatable {
        public let mood: String
        public let uniqueElements: [String]
        public let overallScore: Int
        public let suggestions: [String]
        
        private enum CodingKeys: String, CodingKey {
            case mood
            case uniqueElements = "unique_elements"
            case overallScore = "overall_score"
            case suggestions
        }
    }
}

// MARK: - Preview Support
#if DEBUG
public extension SkinAnalysisModels.Response {
    static var preview: Self {
        .init(
            result: .init(
                photoAnalysis: .init(
                    composition: .init(
                        description: "Well-balanced composition",
                        notableElements: ["Good framing", "Rule of thirds"],
                        compositionScore: 85
                    ),
                    lighting: .init(
                        description: "Even lighting with good contrast",
                        notableElements: ["Natural light", "Soft shadows"],
                        lightingScore: 90
                    ),
                    color: .init(
                        palette: "Natural skin tones with good color balance",
                        notableElements: ["Warm tones", "Even skin tone"],
                        colorScore: 88
                    ),
                    technicalQuality: .init(
                        sharpness: "Image is sharp and clear",
                        exposure: "Well exposed with good detail",
                        depthOfField: "Nice background blur",
                        qualityScore: 92
                    ),
                    facialFeatures: .init(
                        overallStructure: .init(description: "Well-proportioned", balanceScore: 90),
                        skinQuality: .init(description: "Clear and healthy", clarityScore: 85),
                        eyeArea: .init(description: "Well-defined", harmonyScore: 88),
                        mouthArea: .init(description: "Natural expression", proportionScore: 87),
                        noseArea: .init(description: "Well-balanced", balanceScore: 89),
                        cheekArea: .init(description: "Good contours", contourScore: 86),
                        jawArea: .init(description: "Strong definition", definitionScore: 88)
                    )
                ),
                overallImpression: .init(
                    mood: "Professional and natural",
                    uniqueElements: ["Natural expression", "Good lighting"],
                    overallScore: 89,
                    suggestions: ["Consider warmer lighting"]
                )
            ),
            status: "success",
            message: "Analysis complete",
            time: 1234567890,
            cacheTime: 1234567890
        )
    }
}
#endif

#endif
