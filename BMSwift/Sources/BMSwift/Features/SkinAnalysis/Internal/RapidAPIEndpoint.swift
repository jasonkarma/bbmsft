#if canImport(UIKit) && os(iOS)
import Foundation

// MARK: - RapidAPI Configuration
enum RapidAPIConfig {
    static let configuration = BMNetwork.Configuration(
        baseURL: URL(string: "https://face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com")!,
        defaultHeaders: [
            "x-rapidapi-key": "0fc47de525mshb9e37b660469c06p1c82b4jsnc54f0234e207",
            "x-rapidapi-host": "face-beauty-score-api-skin-analyze-attractiveness-test.p.rapidapi.com",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    )
}

// MARK: - RapidAPI
public enum RapidAPI {
    // MARK: - API Response Types
    public struct Response: Codable {
        public let result: Result
        public let status: String
        public let message: String
        public let time: TimeInterval
        public let cacheTime: TimeInterval
    }
    
    public struct Result: Codable {
        public let photoAnalysis: PhotoAnalysis
        public let overallImpression: OverallImpression
        
        enum CodingKeys: String, CodingKey {
            case photoAnalysis = "photo_analysis"
            case overallImpression = "overall_impression"
        }
    }
    
    public struct PhotoAnalysis: Codable {
        public let composition: CompositionAnalysis
        public let lighting: LightingAnalysis
        public let color: ColorAnalysis
        public let technicalQuality: TechnicalQuality
        public let facialFeatures: FacialFeatures
        
        enum CodingKeys: String, CodingKey {
            case composition
            case lighting
            case color
            case technicalQuality = "technical_quality"
            case facialFeatures = "facial_features"
        }
    }
    
    public struct CompositionAnalysis: Codable {
        public let description: String
        public let notableElements: [String]
        public let compositionScore: Double
        
        enum CodingKeys: String, CodingKey {
            case description
            case notableElements = "notable_elements"
            case compositionScore = "composition_score"
        }
    }
    
    public struct LightingAnalysis: Codable {
        public let description: String
        public let notableElements: [String]
        public let lightingScore: Double
        
        enum CodingKeys: String, CodingKey {
            case description
            case notableElements = "notable_elements"
            case lightingScore = "lighting_score"
        }
    }
    
    public struct ColorAnalysis: Codable {
        public let palette: String
        public let notableElements: [String]
        public let colorScore: Double
        
        enum CodingKeys: String, CodingKey {
            case palette
            case notableElements = "notable_elements"
            case colorScore = "color_score"
        }
    }
    
    public struct TechnicalQuality: Codable {
        public let sharpness: String
        public let exposure: String
        public let depthOfField: String
        public let qualityScore: Double
        
        enum CodingKeys: String, CodingKey {
            case sharpness
            case exposure
            case depthOfField = "depth_of_field"
            case qualityScore = "quality_score"
        }
    }
    
    public struct FacialFeatures: Codable {
        public let overallStructure: FeatureAnalysis
        public let skinQuality: FeatureAnalysis
        public let eyeArea: FeatureAnalysis
        public let mouthArea: FeatureAnalysis
        public let noseArea: FeatureAnalysis
        public let cheekArea: FeatureAnalysis
        public let jawArea: FeatureAnalysis
        
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
    
    public struct FeatureAnalysis: Codable {
        public let description: String
        public let score: Double
        
        private enum CodingKeys: String, CodingKey {
            case description
            case balanceScore = "balance_score"
            case clarityScore = "clarity_score"
            case harmonyScore = "harmony_score"
            case proportionScore = "proportion_score"
            case contourScore = "contour_score"
            case definitionScore = "definition_score"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            description = try container.decode(String.self, forKey: .description)
            
            // Try decoding each possible score key
            if let balanceScore = try? container.decode(Double.self, forKey: .balanceScore) {
                score = balanceScore
            } else if let clarityScore = try? container.decode(Double.self, forKey: .clarityScore) {
                score = clarityScore
            } else if let harmonyScore = try? container.decode(Double.self, forKey: .harmonyScore) {
                score = harmonyScore
            } else if let proportionScore = try? container.decode(Double.self, forKey: .proportionScore) {
                score = proportionScore
            } else if let contourScore = try? container.decode(Double.self, forKey: .contourScore) {
                score = contourScore
            } else if let definitionScore = try? container.decode(Double.self, forKey: .definitionScore) {
                score = definitionScore
            } else {
                throw DecodingError.dataCorruptedError(forKey: .balanceScore, in: container, debugDescription: "No valid score found")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(description, forKey: .description)
            // Since we don't know which score type this is, we'll encode it as balance_score
            try container.encode(score, forKey: .balanceScore)
        }
    }
    
    public struct OverallImpression: Codable {
        public let mood: String
        public let uniqueElements: [String]
        public let overallScore: Double
        public let suggestions: [String]
        
        enum CodingKeys: String, CodingKey {
            case mood
            case uniqueElements = "unique_elements"
            case overallScore = "overall_score"
            case suggestions
        }
    }
    
    // MARK: - API Endpoint
    public struct Endpoint: BMNetwork.APIEndpoint {
        public typealias RequestType = AnalyzeRequest
        public typealias ResponseType = Response
        
        public let path: String = "/analyze"
        public let method: BMNetwork.HTTPMethod = .post
        public let requiresAuth: Bool = false
        public let headers: [String: String]
        public let baseURL: URL?
        
        public let imageUrl: String
        public let language: String
        
        public init(imageUrl: String, language: String = "en") {
            self.imageUrl = imageUrl
            self.language = language
            self.headers = RapidAPIConfig.configuration.defaultHeaders
            self.baseURL = RapidAPIConfig.configuration.baseURL
        }
    }
    
    public struct AnalyzeRequest: Codable {
        public let imageUrl: String
        
        enum CodingKeys: String, CodingKey {
            case imageUrl = "from"
        }
        
        public init(imageUrl: String) {
            self.imageUrl = imageUrl
        }
    }
}

#endif
