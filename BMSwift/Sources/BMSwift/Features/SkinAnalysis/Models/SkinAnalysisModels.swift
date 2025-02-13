#if canImport(UIKit) && os(iOS)
import Foundation

/// Models for the Skin Analysis feature
public enum SkinAnalysisModels {
    // MARK: - Response Types
    public struct Response: Codable, Equatable {
        public let imageId: String
        public let requestId: String
        public let timeUsed: Int
        public let faces: [Face]
        public let faceNum: Int
        
        private enum CodingKeys: String, CodingKey {
            case imageId = "image_id"
            case requestId = "request_id"
            case timeUsed = "time_used"
            case faces
            case faceNum = "face_num"
        }
    }
    
    public struct Face: Codable, Equatable {
        public let attributes: Attributes
        public let faceRectangle: FaceRectangle
        public let faceToken: String
        
        private enum CodingKeys: String, CodingKey {
            case attributes
            case faceRectangle = "face_rectangle"
            case faceToken = "face_token"
        }
    }
    
    public struct Attributes: Codable, Equatable {
        public let gender: Gender
        public let age: Age
        public let glass: Glass
        public let headpose: Headpose
        public let smile: Smile
        public let skinstatus: SkinStatus
        public let beauty: Beauty
        
        private enum CodingKeys: String, CodingKey {
            case gender, age, glass, headpose, smile, skinstatus, beauty
        }
    }
    
    public struct Gender: Codable, Equatable {
        public let value: String
    }
    
    public struct Age: Codable, Equatable {
        public let value: Int
    }
    
    public struct Glass: Codable, Equatable {
        public let value: String
    }
    
    public struct Headpose: Codable, Equatable {
        public let yawAngle: Double
        public let pitchAngle: Double
        public let rollAngle: Double
        
        private enum CodingKeys: String, CodingKey {
            case yawAngle = "yaw_angle"
            case pitchAngle = "pitch_angle"
            case rollAngle = "roll_angle"
        }
    }
    
    public struct Smile: Codable, Equatable {
        public let threshold: Double
        public let value: Double
    }
    
    public struct SkinStatus: Codable, Equatable {
        public let health: Double
        public let stain: Double
        public let acne: Double
        public let darkCircle: Double
        
        private enum CodingKeys: String, CodingKey {
            case health, stain, acne
            case darkCircle = "dark_circle"
        }
    }
    
    public struct Beauty: Codable, Equatable {
        public let maleScore: Double
        public let femaleScore: Double
        
        private enum CodingKeys: String, CodingKey {
            case maleScore = "male_score"
            case femaleScore = "female_score"
        }
    }
    
    public struct FaceRectangle: Codable, Equatable {
        public let width: Int
        public let top: Int
        public let left: Int
        public let height: Int
    }
}

// MARK: - Preview Support
#if DEBUG
public extension SkinAnalysisModels.Response {
    static var preview: Self {
        .init(
            imageId: "preview_image_id",
            requestId: "preview_request_id",
            timeUsed: 234,
            faces: [.preview],
            faceNum: 1
        )
    }
}

public extension SkinAnalysisModels.Face {
    static var preview: Self {
        .init(
            attributes: .preview,
            faceRectangle: .preview,
            faceToken: "preview_face_token"
        )
    }
}

public extension SkinAnalysisModels.Attributes {
    static var preview: Self {
        .init(
            gender: .init(value: "Female"),
            age: .init(value: 25),
            glass: .init(value: "None"),
            headpose: .preview,
            smile: .init(threshold: 50.0, value: 75.5),
            skinstatus: .preview,
            beauty: .preview
        )
    }
}

public extension SkinAnalysisModels.Headpose {
    static var preview: Self {
        .init(yawAngle: -2.5, pitchAngle: 1.2, rollAngle: 0.8)
    }
}

public extension SkinAnalysisModels.SkinStatus {
    static var preview: Self {
        .init(health: 85.5, stain: 12.3, acne: 5.6, darkCircle: 15.2)
    }
}

public extension SkinAnalysisModels.Beauty {
    static var preview: Self {
        .init(maleScore: 80.5, femaleScore: 85.2)
    }
}

public extension SkinAnalysisModels.FaceRectangle {
    static var preview: Self {
        .init(width: 200, top: 100, left: 150, height: 200)
    }
}
#endif
#endif
