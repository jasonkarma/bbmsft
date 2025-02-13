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
    }
    
    // MARK: - Face Rectangle Model
    public struct FaceRectangle: Codable, Equatable {
        public let top: Int
        public let left: Int
        public let width: Int
        public let height: Int
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
    }
    
    // MARK: - Basic Value Types
    public struct Gender: Codable, Equatable { public let value: String }
    public struct Age: Codable, Equatable { public let value: Int }
    public struct Glass: Codable, Equatable { public let value: String }
    
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
    }
    
    // MARK: - Smile Model
    public struct Smile: Codable, Equatable {
        public let threshold: Float
        public let value: Float
    }
    
    // MARK: - Eye Status Model
    public struct EyeStatus: Codable, Equatable {
        public let leftEye: EyeDetail
        public let rightEye: EyeDetail
        
        private enum CodingKeys: String, CodingKey {
            case leftEye = "left_eye"
            case rightEye = "right_eye"
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
    }
    
    // MARK: - Face Quality Model
    public struct FaceQuality: Codable, Equatable {
        public let threshold: Float
        public let value: Float
    }
    
    // MARK: - Beauty Model
    public struct Beauty: Codable, Equatable {
        public let femaleScore: Float
        public let maleScore: Float
        
        private enum CodingKeys: String, CodingKey {
            case femaleScore = "female_score"
            case maleScore = "male_score"
        }
    }
    
    // MARK: - Mouth Status Model
    public struct MouthStatus: Codable, Equatable {
        public let otherOcclusion: Float
        public let surgicalMaskOrRespirator: Float
        public let closeWithMask: Float
        public let openWithMask: Float
        public let close: Float
        public let open: Float
        
        private enum CodingKeys: String, CodingKey {
            case otherOcclusion = "other_occlusion"
            case surgicalMaskOrRespirator = "surgical_mask_or_respirator"
            case closeWithMask = "close_with_mask"
            case openWithMask = "open_with_mask"
            case close
            case open
        }
    }
    
    // MARK: - Eye Gaze Model
    public struct EyeGaze: Codable, Equatable {
        public let rightEye: GazeDirection
        public let leftEye: GazeDirection
        
        private enum CodingKeys: String, CodingKey {
            case rightEye = "right_eye"
            case leftEye = "left_eye"
        }
    }
    
    public struct GazeDirection: Codable, Equatable {
        public let vectorZComponent: VectorComponent
        public let vectorXComponent: VectorComponent
        public let vectorYComponent: VectorComponent
        public let position: Position
        
        private enum CodingKeys: String, CodingKey {
            case vectorZComponent = "vector_z_component"
            case vectorXComponent = "vector_x_component"
            case vectorYComponent = "vector_y_component"
            case position
        }
    }
    
    public struct VectorComponent: Codable, Equatable {
        public let value: Float
    }
    
    public struct Position: Codable, Equatable {
        public let xCoordinate: Float
        public let yCoordinate: Float
        
        private enum CodingKeys: String, CodingKey {
            case xCoordinate = "x_coordinate"
            case yCoordinate = "y_coordinate"
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
                            closeWithMask: 0.0,
                            openWithMask: 0.0,
                            close: 0.0,
                            open: 1.0
                        ),
                        eyegaze: SkinAnalysisModels.EyeGaze(
                            rightEye: SkinAnalysisModels.GazeDirection(
                                vectorZComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                vectorXComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                vectorYComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                position: SkinAnalysisModels.Position(
                                    xCoordinate: 0.0,
                                    yCoordinate: 0.0
                                )
                            ),
                            leftEye: SkinAnalysisModels.GazeDirection(
                                vectorZComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                vectorXComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                vectorYComponent: SkinAnalysisModels.VectorComponent(value: 0.0),
                                position: SkinAnalysisModels.Position(
                                    xCoordinate: 0.0,
                                    yCoordinate: 0.0
                                )
                            )
                        ),
                        skinstatus: SkinAnalysisModels.SkinStatus(
                            health: 85.0,
                            stain: 15.0,
                            acne: 10.0,
                            darkCircle: 25.0
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
