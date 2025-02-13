#if canImport(Foundation)
import Foundation

// MARK: - Request Models
public struct FacePlusPlusDetectRequest {
    let apiKey: String
    let apiSecret: String
    let imageData: Data?
    let imageURL: String?
    let imageBase64: String?
    let returnLandmark: Int?
    let returnAttributes: String?
    
    public init(
        apiKey: String,
        apiSecret: String,
        imageData: Data? = nil,
        imageURL: String? = nil,
        imageBase64: String? = nil,
        returnLandmark: Int? = 1,
        returnAttributes: String? = "gender,age,glass,headpose,smile,blur,eyestatus,emotion,facequality,beauty,mouthstatus,eyegaze,skinstatus"
    ) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.imageData = imageData
        self.imageURL = imageURL
        self.imageBase64 = imageBase64
        self.returnLandmark = returnLandmark
        self.returnAttributes = returnAttributes
    }
}

// MARK: - Response Models
public struct FacePlusPlusDetectResponse: Codable {
    public let imageId: String
    public let requestId: String
    public let timeUsed: Int
    public let faces: [Face]
    public let faceNum: Int
    
    enum CodingKeys: String, CodingKey {
        case imageId = "image_id"
        case requestId = "request_id"
        case timeUsed = "time_used"
        case faces
        case faceNum = "face_num"
    }
}

public struct Face: Codable {
    public let landmark: [String: Point]?
    public let attributes: Attributes
    public let faceRectangle: FaceRectangle
    public let faceToken: String
    
    enum CodingKeys: String, CodingKey {
        case landmark
        case attributes
        case faceRectangle = "face_rectangle"
        case faceToken = "face_token"
    }
}

public struct Point: Codable {
    public let x: Double
    public let y: Double
}

public struct Attributes: Codable {
    public let gender: Gender
    public let age: Age
    public let glass: Glass
    public let headpose: Headpose
    public let smile: Smile
    public let blur: Blur?
    public let eyestatus: EyeStatus?
    public let emotion: Emotion?
    public let facequality: FaceQuality?
    public let beauty: Beauty?
    public let mouthstatus: MouthStatus?
    public let eyegaze: EyeGaze?
    public let skinstatus: SkinStatus?
}

public struct Gender: Codable {
    public let value: String
}

public struct Age: Codable {
    public let value: Int
}

public struct Glass: Codable {
    public let value: String
}

public struct Headpose: Codable {
    public let yawAngle: Double
    public let pitchAngle: Double
    public let rollAngle: Double
    
    enum CodingKeys: String, CodingKey {
        case yawAngle = "yaw_angle"
        case pitchAngle = "pitch_angle"
        case rollAngle = "roll_angle"
    }
}

public struct Smile: Codable {
    public let threshold: Double
    public let value: Double
}

public struct Blur: Codable {
    public let blurness: ValueThreshold
}

public struct ValueThreshold: Codable {
    public let threshold: Double
    public let value: Double
}

public struct EyeStatus: Codable {
    public let leftEyeStatus: EyeStatusDetail
    public let rightEyeStatus: EyeStatusDetail
    
    enum CodingKeys: String, CodingKey {
        case leftEyeStatus = "left_eye_status"
        case rightEyeStatus = "right_eye_status"
    }
}

public struct EyeStatusDetail: Codable {
    public let normalGlassEyeOpen: Double
    public let noGlassEyeClose: Double
    public let occlusion: Double
    public let noGlassEyeOpen: Double
    public let normalGlassEyeClose: Double
    public let darkGlasses: Double
    
    enum CodingKeys: String, CodingKey {
        case normalGlassEyeOpen = "normal_glass_eye_open"
        case noGlassEyeClose = "no_glass_eye_close"
        case occlusion
        case noGlassEyeOpen = "no_glass_eye_open"
        case normalGlassEyeClose = "normal_glass_eye_close"
        case darkGlasses = "dark_glasses"
    }
}

public struct Emotion: Codable {
    public let anger: Double
    public let disgust: Double
    public let fear: Double
    public let happiness: Double
    public let neutral: Double
    public let sadness: Double
    public let surprise: Double
}

public struct FaceQuality: Codable {
    public let value: Double
    public let threshold: Double
}

public struct Beauty: Codable {
    public let maleScore: Double
    public let femaleScore: Double
    
    enum CodingKeys: String, CodingKey {
        case maleScore = "male_score"
        case femaleScore = "female_score"
    }
}

public struct MouthStatus: Codable {
    public let surgicalMaskOrRespirator: Double
    public let otherOcclusion: Double
    public let close: Double
    public let open: Double
    
    enum CodingKeys: String, CodingKey {
        case surgicalMaskOrRespirator = "surgical_mask_or_respirator"
        case otherOcclusion = "other_occlusion"
        case close
        case open
    }
}

public struct EyeGaze: Codable {
    public let leftEyeGaze: GazeDetail
    public let rightEyeGaze: GazeDetail
    
    enum CodingKeys: String, CodingKey {
        case leftEyeGaze = "left_eye_gaze"
        case rightEyeGaze = "right_eye_gaze"
    }
}

public struct GazeDetail: Codable {
    public let positionXCoordinate: Double
    public let positionYCoordinate: Double
    public let vectorXComponent: Double
    public let vectorYComponent: Double
    public let vectorZComponent: Double
    
    enum CodingKeys: String, CodingKey {
        case positionXCoordinate = "position_x_coordinate"
        case positionYCoordinate = "position_y_coordinate"
        case vectorXComponent = "vector_x_component"
        case vectorYComponent = "vector_y_component"
        case vectorZComponent = "vector_z_component"
    }
}

public struct SkinStatus: Codable {
    public let health: Double
    public let stain: Double
    public let acne: Double
    public let darkCircle: Double
    
    enum CodingKeys: String, CodingKey {
        case health
        case stain
        case acne
        case darkCircle = "dark_circle"
    }
}

public struct FaceRectangle: Codable {
    public let width: Int
    public let top: Int
    public let left: Int
    public let height: Int
}

// MARK: - Error Models
public struct FacePlusPlusError: Codable {
    public let timeUsed: Int
    public let errorMessage: String
    public let requestId: String
    
    enum CodingKeys: String, CodingKey {
        case timeUsed = "time_used"
        case errorMessage = "error_message"
        case requestId = "request_id"
    }
}
#endif
