#if canImport(UIKit) && os(iOS)
import Foundation

/// Models for the skin analysis feature
public enum SkinAnalysisModels {
    
    // MARK: - Response Model
    public struct Response: Codable, Equatable {
        public let requestId: String
        public let timeUsed: Int
        public let faces: [Face]
        public let imageId: String
        public let faceNum: Int?
        public let errorMessage: String?
        
        private enum CodingKeys: String, CodingKey {
            case requestId = "request_id"
            case timeUsed = "time_used"
            case faces
            case imageId = "image_id"
            case faceNum = "face_num"
            case errorMessage = "error_message"
        }
        
        public init(requestId: String, timeUsed: Int, faces: [Face], imageId: String, faceNum: Int?, errorMessage: String?) {
            self.requestId = requestId
            self.timeUsed = timeUsed
            self.faces = faces
            self.imageId = imageId
            self.faceNum = faceNum
            self.errorMessage = errorMessage
        }
    }
    
    // MARK: - Face Model
    public struct Face: Codable, Equatable {
        public let faceToken: String
        public let faceRectangle: FaceRectangle
        public let attributes: Attributes
        
        private enum CodingKeys: String, CodingKey {
            case faceToken = "face_token"
            case faceRectangle = "face_rectangle"
            case attributes
        }
        
        public init(faceToken: String, faceRectangle: FaceRectangle, attributes: Attributes) {
            self.faceToken = faceToken
            self.faceRectangle = faceRectangle
            self.attributes = attributes
        }
    }
    
    // MARK: - Face Rectangle Model
    public struct FaceRectangle: Codable, Equatable {
        public let top: Int
        public let left: Int
        public let width: Int
        public let height: Int
        
        public init(top: Int, left: Int, width: Int, height: Int) {
            self.top = top
            self.left = left
            self.width = width
            self.height = height
        }
    }
    
    // MARK: - Attributes Model
    public struct Attributes: Codable, Equatable {
        public let gender: Gender
        public let age: Age
        public let glass: Glass
        public let headpose: Headpose
        public let smile: Smile
        public let eyestatus: EyeStatus
        public let emotion: Emotion
        public let facequality: FaceQuality
        public let beauty: Beauty
        public let mouthstatus: MouthStatus
        public let eyegaze: EyeGaze
        public let skinstatus: SkinStatus
        public let blur: Blur
        
        public init(gender: Gender, age: Age, glass: Glass, headpose: Headpose, smile: Smile, eyestatus: EyeStatus, emotion: Emotion, facequality: FaceQuality, beauty: Beauty, mouthstatus: MouthStatus, eyegaze: EyeGaze, skinstatus: SkinStatus, blur: Blur) {
            self.gender = gender
            self.age = age
            self.glass = glass
            self.headpose = headpose
            self.smile = smile
            self.eyestatus = eyestatus
            self.emotion = emotion
            self.facequality = facequality
            self.beauty = beauty
            self.mouthstatus = mouthstatus
            self.eyegaze = eyegaze
            self.skinstatus = skinstatus
            self.blur = blur
        }
    }
    
    // MARK: - Basic Value Types
    public struct Gender: Codable, Equatable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    public struct Age: Codable, Equatable {
        public let value: Int
        
        public init(value: Int) {
            self.value = value
        }
    }
    
    public struct Glass: Codable, Equatable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    // MARK: - Blur Model
    public struct Blur: Codable, Equatable {
        public let blurness: BlurDetail
        public let gaussianblur: BlurDetail
        public let motionblur: BlurDetail
        
        public init(blurness: BlurDetail, gaussianblur: BlurDetail, motionblur: BlurDetail) {
            self.blurness = blurness
            self.gaussianblur = gaussianblur
            self.motionblur = motionblur
        }
    }
    
    public struct BlurDetail: Codable, Equatable {
        public let threshold: Float
        public let value: Float
        
        public init(threshold: Float, value: Float) {
            self.threshold = threshold
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            if let stringValue = try? container.decode(String.self, forKey: .threshold) {
                threshold = Float(stringValue) ?? 0.0
            } else {
                threshold = try container.decode(Float.self, forKey: .threshold)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .value) {
                value = Float(stringValue) ?? 0.0
            } else {
                value = try container.decode(Float.self, forKey: .value)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case threshold, value
        }
    }
    
    // MARK: - Headpose Model
    public struct Headpose: Codable, Equatable {
        public let yawAngle: Float
        public let pitchAngle: Float
        public let rollAngle: Float
        
        private enum CodingKeys: String, CodingKey {
            case yawAngle = "yaw_angle"
            case pitchAngle = "pitch_angle"
            case rollAngle = "roll_angle"
        }
        
        public init(yawAngle: Float, pitchAngle: Float, rollAngle: Float) {
            self.yawAngle = yawAngle
            self.pitchAngle = pitchAngle
            self.rollAngle = rollAngle
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            if let stringValue = try? container.decode(String.self, forKey: .yawAngle) {
                yawAngle = Float(stringValue) ?? 0.0
            } else {
                yawAngle = try container.decode(Float.self, forKey: .yawAngle)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .pitchAngle) {
                pitchAngle = Float(stringValue) ?? 0.0
            } else {
                pitchAngle = try container.decode(Float.self, forKey: .pitchAngle)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .rollAngle) {
                rollAngle = Float(stringValue) ?? 0.0
            } else {
                rollAngle = try container.decode(Float.self, forKey: .rollAngle)
            }
        }
    }
    
    // MARK: - Smile Model
    public struct Smile: Codable, Equatable {
        public let threshold: Float
        public let value: Float
        
        public init(threshold: Float, value: Float) {
            self.threshold = threshold
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            if let stringValue = try? container.decode(String.self, forKey: .threshold) {
                threshold = Float(stringValue) ?? 0.0
            } else {
                threshold = try container.decode(Float.self, forKey: .threshold)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .value) {
                value = Float(stringValue) ?? 0.0
            } else {
                value = try container.decode(Float.self, forKey: .value)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case threshold, value
        }
    }
    
    // MARK: - Eye Status Model
    public struct EyeStatus: Codable, Equatable {
        public let leftEye: EyeDetail
        public let rightEye: EyeDetail
        
        private enum CodingKeys: String, CodingKey {
            case leftEye = "left_eye_status"
            case rightEye = "right_eye_status"
        }
        
        public init(leftEye: EyeDetail, rightEye: EyeDetail) {
            self.leftEye = leftEye
            self.rightEye = rightEye
        }
    }
    
    public struct EyeDetail: Codable, Equatable {
        public let normalGlassEyeOpen: Float
        public let noGlassEyeClose: Float
        public let occlusion: Float
        public let noGlassEyeOpen: Float
        public let normalGlassEyeClose: Float
        public let darkGlasses: Float
        
        private enum CodingKeys: String, CodingKey {
            case normalGlassEyeOpen = "normal_glass_eye_open"
            case noGlassEyeClose = "no_glass_eye_close"
            case occlusion
            case noGlassEyeOpen = "no_glass_eye_open"
            case normalGlassEyeClose = "normal_glass_eye_close"
            case darkGlasses = "dark_glasses"
        }
        
        public init(normalGlassEyeOpen: Float, noGlassEyeClose: Float, occlusion: Float, noGlassEyeOpen: Float, normalGlassEyeClose: Float, darkGlasses: Float) {
            self.normalGlassEyeOpen = normalGlassEyeOpen
            self.noGlassEyeClose = noGlassEyeClose
            self.occlusion = occlusion
            self.noGlassEyeOpen = noGlassEyeOpen
            self.normalGlassEyeClose = normalGlassEyeClose
            self.darkGlasses = darkGlasses
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            func decodeFloat(_ key: CodingKeys) throws -> Float {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return Float(stringValue) ?? 0.0
                }
                return try container.decode(Float.self, forKey: key)
            }
            
            normalGlassEyeOpen = try decodeFloat(.normalGlassEyeOpen)
            noGlassEyeClose = try decodeFloat(.noGlassEyeClose)
            occlusion = try decodeFloat(.occlusion)
            noGlassEyeOpen = try decodeFloat(.noGlassEyeOpen)
            normalGlassEyeClose = try decodeFloat(.normalGlassEyeClose)
            darkGlasses = try decodeFloat(.darkGlasses)
        }
    }
    
    // MARK: - Emotion Model
    public struct Emotion: Codable, Equatable {
        public let anger: Float
        public let disgust: Float
        public let fear: Float
        public let happiness: Float
        public let neutral: Float
        public let sadness: Float
        public let surprise: Float
        
        public init(anger: Float, disgust: Float, fear: Float, happiness: Float, neutral: Float, sadness: Float, surprise: Float) {
            self.anger = anger
            self.disgust = disgust
            self.fear = fear
            self.happiness = happiness
            self.neutral = neutral
            self.sadness = sadness
            self.surprise = surprise
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            func decodeFloat(_ key: CodingKeys) throws -> Float {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return Float(stringValue) ?? 0.0
                }
                return try container.decode(Float.self, forKey: key)
            }
            
            anger = try decodeFloat(.anger)
            disgust = try decodeFloat(.disgust)
            fear = try decodeFloat(.fear)
            happiness = try decodeFloat(.happiness)
            neutral = try decodeFloat(.neutral)
            sadness = try decodeFloat(.sadness)
            surprise = try decodeFloat(.surprise)
        }
        
        private enum CodingKeys: String, CodingKey {
            case anger, disgust, fear, happiness, neutral, sadness, surprise
        }
    }
    
    // MARK: - Face Quality Model
    public struct FaceQuality: Codable, Equatable {
        public let threshold: Float
        public let value: Float
        
        public init(threshold: Float, value: Float) {
            self.threshold = threshold
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            if let stringValue = try? container.decode(String.self, forKey: .threshold) {
                threshold = Float(stringValue) ?? 0.0
            } else {
                threshold = try container.decode(Float.self, forKey: .threshold)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .value) {
                value = Float(stringValue) ?? 0.0
            } else {
                value = try container.decode(Float.self, forKey: .value)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case threshold, value
        }
    }
    
    // MARK: - Beauty Model
    public struct Beauty: Codable, Equatable {
        public let femaleScore: Float
        public let maleScore: Float
        
        private enum CodingKeys: String, CodingKey {
            case femaleScore = "female_score"
            case maleScore = "male_score"
        }
        
        public init(femaleScore: Float, maleScore: Float) {
            self.femaleScore = femaleScore
            self.maleScore = maleScore
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            if let stringValue = try? container.decode(String.self, forKey: .femaleScore) {
                femaleScore = Float(stringValue) ?? 0.0
            } else {
                femaleScore = try container.decode(Float.self, forKey: .femaleScore)
            }
            
            if let stringValue = try? container.decode(String.self, forKey: .maleScore) {
                maleScore = Float(stringValue) ?? 0.0
            } else {
                maleScore = try container.decode(Float.self, forKey: .maleScore)
            }
        }
    }
    
    // MARK: - Mouth Status Model
    public struct MouthStatus: Codable, Equatable {
        public let otherOcclusion: Float
        public let surgicalMaskOrRespirator: Float
        public let close: Float
        public let open: Float
        
        private enum CodingKeys: String, CodingKey {
            case otherOcclusion = "other_occlusion"
            case surgicalMaskOrRespirator = "surgical_mask_or_respirator"
            case close
            case open
        }
        
        public init(otherOcclusion: Float, surgicalMaskOrRespirator: Float, close: Float, open: Float) {
            self.otherOcclusion = otherOcclusion
            self.surgicalMaskOrRespirator = surgicalMaskOrRespirator
            self.close = close
            self.open = open
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            func decodeFloat(_ key: CodingKeys) throws -> Float {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return Float(stringValue) ?? 0.0
                }
                return try container.decode(Float.self, forKey: key)
            }
            
            otherOcclusion = try decodeFloat(.otherOcclusion)
            surgicalMaskOrRespirator = try decodeFloat(.surgicalMaskOrRespirator)
            close = try decodeFloat(.close)
            open = try decodeFloat(.open)
        }
    }
    
    // MARK: - Eye Gaze Model
    public struct EyeGaze: Codable, Equatable {
        public let rightEye: GazeDirection
        public let leftEye: GazeDirection
        
        private enum CodingKeys: String, CodingKey {
            case rightEye = "right_eye_gaze"
            case leftEye = "left_eye_gaze"
        }
        
        public init(rightEye: GazeDirection, leftEye: GazeDirection) {
            self.rightEye = rightEye
            self.leftEye = leftEye
        }
    }
    
    public struct GazeDirection: Codable, Equatable {
        public let vectorZComponent: Float
        public let vectorXComponent: Float
        public let vectorYComponent: Float
        public let positionXCoordinate: Float
        public let positionYCoordinate: Float
        
        private enum CodingKeys: String, CodingKey {
            case vectorZComponent = "vector_z_component"
            case vectorXComponent = "vector_x_component"
            case vectorYComponent = "vector_y_component"
            case positionXCoordinate = "position_x_coordinate"
            case positionYCoordinate = "position_y_coordinate"
        }
        
        public init(vectorZComponent: Float, vectorXComponent: Float, vectorYComponent: Float, positionXCoordinate: Float, positionYCoordinate: Float) {
            self.vectorZComponent = vectorZComponent
            self.vectorXComponent = vectorXComponent
            self.vectorYComponent = vectorYComponent
            self.positionXCoordinate = positionXCoordinate
            self.positionYCoordinate = positionYCoordinate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            func decodeFloat(_ key: CodingKeys) throws -> Float {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return Float(stringValue) ?? 0.0
                }
                return try container.decode(Float.self, forKey: key)
            }
            
            vectorZComponent = try decodeFloat(.vectorZComponent)
            vectorXComponent = try decodeFloat(.vectorXComponent)
            vectorYComponent = try decodeFloat(.vectorYComponent)
            positionXCoordinate = try decodeFloat(.positionXCoordinate)
            positionYCoordinate = try decodeFloat(.positionYCoordinate)
        }
    }
    
    // MARK: - Skin Status Model
    public struct SkinStatus: Codable, Equatable {
        public let health: Float
        public let stain: Float
        public let acne: Float
        public let darkCircle: Float
        
        private enum CodingKeys: String, CodingKey {
            case health
            case stain
            case acne
            case darkCircle = "dark_circle"
        }
        
        public init(health: Float, stain: Float, acne: Float, darkCircle: Float) {
            self.health = health
            self.stain = stain
            self.acne = acne
            self.darkCircle = darkCircle
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Handle potential string values
            func decodeFloat(_ key: CodingKeys) throws -> Float {
                if let stringValue = try? container.decode(String.self, forKey: key) {
                    return Float(stringValue) ?? 0.0
                }
                return try container.decode(Float.self, forKey: key)
            }
            
            health = try decodeFloat(.health)
            stain = try decodeFloat(.stain)
            acne = try decodeFloat(.acne)
            darkCircle = try decodeFloat(.darkCircle)
        }
    }
}

// MARK: - Preview Support
#if DEBUG
public extension SkinAnalysisModels.Response {
    /// Creates a preview instance of the response with mock data
    static var preview: SkinAnalysisModels.Response {
        SkinAnalysisModels.Response(
            requestId: "mock_request_id",
            timeUsed: 100,
            faces: [
                SkinAnalysisModels.Face(
                    faceToken: "mock_token",
                    faceRectangle: SkinAnalysisModels.FaceRectangle(
                        top: 100,
                        left: 100,
                        width: 200,
                        height: 200
                    ),
                    attributes: SkinAnalysisModels.Attributes(
                        gender: SkinAnalysisModels.Gender(value: "Female"),
                        age: SkinAnalysisModels.Age(value: 25),
                        glass: SkinAnalysisModels.Glass(value: "None"),
                        headpose: SkinAnalysisModels.Headpose(
                            yawAngle: 0,
                            pitchAngle: 0,
                            rollAngle: 0
                        ),
                        smile: SkinAnalysisModels.Smile(
                            threshold: 50.0,
                            value: 75.0
                        ),
                        eyestatus: SkinAnalysisModels.EyeStatus(
                            leftEye: SkinAnalysisModels.EyeDetail(
                                normalGlassEyeOpen: 1.0,
                                noGlassEyeClose: 0.0,
                                occlusion: 0.0,
                                noGlassEyeOpen: 1.0,
                                normalGlassEyeClose: 0.0,
                                darkGlasses: 0.0
                            ),
                            rightEye: SkinAnalysisModels.EyeDetail(
                                normalGlassEyeOpen: 1.0,
                                noGlassEyeClose: 0.0,
                                occlusion: 0.0,
                                noGlassEyeOpen: 1.0,
                                normalGlassEyeClose: 0.0,
                                darkGlasses: 0.0
                            )
                        ),
                        emotion: SkinAnalysisModels.Emotion(
                            anger: 0.0,
                            disgust: 0.0,
                            fear: 0.0,
                            happiness: 100.0,
                            neutral: 0.0,
                            sadness: 0.0,
                            surprise: 0.0
                        ),
                        facequality: SkinAnalysisModels.FaceQuality(
                            threshold: 70.0,
                            value: 85.0
                        ),
                        beauty: SkinAnalysisModels.Beauty(
                            femaleScore: 85.0,
                            maleScore: 0.0
                        ),
                        mouthstatus: SkinAnalysisModels.MouthStatus(
                            otherOcclusion: 0.0,
                            surgicalMaskOrRespirator: 0.0,
                            close: 0.0,
                            open: 1.0
                        ),
                        eyegaze: SkinAnalysisModels.EyeGaze(
                            rightEye: SkinAnalysisModels.GazeDirection(
                                vectorZComponent: 0.0,
                                vectorXComponent: 0.0,
                                vectorYComponent: 0.0,
                                positionXCoordinate: 0.0,
                                positionYCoordinate: 0.0
                            ),
                            leftEye: SkinAnalysisModels.GazeDirection(
                                vectorZComponent: 0.0,
                                vectorXComponent: 0.0,
                                vectorYComponent: 0.0,
                                positionXCoordinate: 0.0,
                                positionYCoordinate: 0.0
                            )
                        ),
                        skinstatus: SkinAnalysisModels.SkinStatus(
                            health: 85.0,
                            stain: 15.0,
                            acne: 10.0,
                            darkCircle: 25.0
                        ),
                        blur: SkinAnalysisModels.Blur(
                            blurness: SkinAnalysisModels.BlurDetail(
                                threshold: 50.0,
                                value: 0.091
                            ),
                            gaussianblur: SkinAnalysisModels.BlurDetail(
                                threshold: 50.0,
                                value: 0.091
                            ),
                            motionblur: SkinAnalysisModels.BlurDetail(
                                threshold: 50.0,
                                value: 0.091
                            )
                        )
                    )
                )
            ],
            imageId: "mock_image_id",
            faceNum: 1,
            errorMessage: nil
        )
    }
}
#endif
#endif
