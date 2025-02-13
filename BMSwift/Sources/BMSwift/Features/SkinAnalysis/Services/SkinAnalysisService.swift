#if canImport(UIKit) && os(iOS)
import Foundation
import UIKit
import Vision

/// Protocol defining the skin analysis service interface
public protocol SkinAnalysisServiceProtocol {
    /// Analyzes the provided image and returns the analysis results
    /// - Parameter image: The image to analyze
    /// - Returns: The analysis response containing skin analysis results
    /// - Throws: SkinAnalysisError if analysis fails
    func analyzeSkin(image: UIImage) async throws -> SkinAnalysisModels.Response
    
    /// Analyzes the provided image URL and returns the analysis results
    /// - Parameter imageUrl: The URL of the image to analyze
    /// - Returns: The analysis response containing skin analysis results
    /// - Throws: SkinAnalysisError if analysis fails
    func analyzeSkin(imageUrl: String) async throws -> SkinAnalysisModels.Response
}

/// Global rate limiter for Face++ API requests
public actor FacePlusPlusRateLimiter {
    public static let shared = FacePlusPlusRateLimiter()
    
    @MainActor private var isProcessing = false
    @MainActor private var lastRequestTime: Date?
    private let minRequestInterval: TimeInterval = 1.0 // Minimum 1 second between requests
    @MainActor private var requestQueue: [CheckedContinuation<Void, Error>] = []
    
    public init() {}
    
    public func waitForTurn() async throws {
        if await isProcessing {
            return try await withCheckedThrowingContinuation { continuation in
                Task { @MainActor in
                    requestQueue.append(continuation)
                }
            }
        }
        
        if let lastTime = await lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastTime)
            if timeSinceLastRequest < minRequestInterval {
                let waitTime = minRequestInterval - timeSinceLastRequest
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        
        await MainActor.run { isProcessing = true }
    }
    
    @MainActor public func finishRequest() {
        isProcessing = false
        lastRequestTime = Date()
        
        if let nextRequest = requestQueue.first {
            requestQueue.removeFirst()
            nextRequest.resume(returning: ())
        }
    }
}

/// Implementation of the skin analysis service
public actor SkinAnalysisServiceImpl: SkinAnalysisServiceProtocol {
    // MARK: - Properties
    private let client: BMNetwork.NetworkClient
    private let rateLimiter: FacePlusPlusRateLimiter
    
    // API requirements
    private let minImageSize: CGFloat = 500
    private let maxImageSize: CGFloat = 2000
    private let maxFileSize: Int = 2 * 1024 * 1024 // 2MB in bytes (Face++ limit)
    private let maxFaceRatio: CGFloat = 0.8
    private let minFaceRatio: CGFloat = 0.2
    
    // MARK: - Initialization
    public init(
        client: BMNetwork.NetworkClient = .shared,
        rateLimiter: FacePlusPlusRateLimiter = .shared
    ) {
        self.client = client
        self.rateLimiter = rateLimiter
    }
    
    // MARK: - Public Methods
    public func analyzeSkin(image: UIImage) async throws -> SkinAnalysisModels.Response {
        // Wait for our turn in the rate limiter
        try await rateLimiter.waitForTurn()
        defer { Task { @MainActor in rateLimiter.finishRequest() } }
        
        print("DEBUG: Original image size: \(image.size)")
        
        // 1. Detect and validate face
        let faceRect = try await detectFace(in: image)
        print("DEBUG: Detected face at: \(faceRect)")
        
        // 2. Process image with face-aware cropping
        let processedImage = try processImage(image, faceRect: faceRect)
        print("DEBUG: Processed image size: \(processedImage.size)")
        
        // 3. Convert to JPEG with appropriate compression
        let imageData = try await compressImage(processedImage)
        print("DEBUG: Final image size: \(imageData.count / 1024)KB")
        
        // 4. Make API request with image data
        let request = SkinAnalysisEndpoints.Analyze.Request(image: imageData)
        return try await client.send(SkinAnalysisEndpoints.analyzeSkin(request: request))
    }
    
    public func analyzeSkin(imageUrl: String) async throws -> SkinAnalysisModels.Response {
        // Wait for our turn in the rate limiter
        try await rateLimiter.waitForTurn()
        defer { Task { @MainActor in rateLimiter.finishRequest() } }
        
        print("DEBUG: Using image URL method with URL: \(imageUrl)")
        let request = SkinAnalysisEndpoints.Analyze.Request(imageUrl: imageUrl)
        return try await client.send(SkinAnalysisEndpoints.analyzeSkin(request: request))
    }
    
    // MARK: - Private Methods
    private func compressImage(_ image: UIImage) async throws -> Data {
        var compressionQuality: CGFloat = 0.9 // Start with high quality
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        // Progressive compression strategy
        while let data = imageData, data.count > maxFileSize && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
            print("DEBUG: Compression attempt - Quality: \(compressionQuality), Size: \(data.count / 1024)KB")
        }
        
        // If still too large, try aggressive compression
        if let data = imageData, data.count > maxFileSize {
            let aggressiveQualities: [CGFloat] = [0.08, 0.05, 0.03]
            
            for quality in aggressiveQualities {
                imageData = image.jpegData(compressionQuality: quality)
                if let data = imageData, data.count <= maxFileSize {
                    compressionQuality = quality
                    print("DEBUG: Aggressive compression successful - Quality: \(quality), Size: \(data.count / 1024)KB")
                    break
                }
            }
        }
        
        guard let finalImageData = imageData else {
            throw BMSwift.SkinAnalysisError.imageCompressionFailed
        }
        
        guard finalImageData.count <= maxFileSize else {
            throw BMSwift.SkinAnalysisError.imageTooLarge(Double(finalImageData.count) / Double(1024 * 1024))
        }
        
        return finalImageData
    }
    
    private func detectFace(in image: UIImage) async throws -> CGRect {
        guard let cgImage = image.cgImage else {
            throw SkinAnalysisError.imageProcessingError
        }
        
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])
        
        guard let observations = request.results else {
            throw SkinAnalysisError.invalidImage
        }
        
        // Ensure only one face
        guard !observations.isEmpty else {
            throw SkinAnalysisError.analysisError("No face detected in the image")
        }
        
        guard observations.count == 1 else {
            throw SkinAnalysisError.analysisError("Multiple faces detected. Please ensure only one face is in frame")
        }
        
        let faceObservation = observations[0]
        let faceRect = VNImageRectForNormalizedRect(faceObservation.boundingBox, Int(image.size.width), Int(image.size.height))
        
        // Validate face size
        let faceRatio = faceRect.height / image.size.height
        if faceRatio > maxFaceRatio {
            throw SkinAnalysisError.analysisError("Face is too close to the camera. Please move back")
        }
        if faceRatio < minFaceRatio {
            throw SkinAnalysisError.analysisError("Face is too far from the camera. Please move closer")
        }
        
        return faceRect
    }
    
    private func processImage(_ image: UIImage, faceRect: CGRect) throws -> UIImage {
        // 1. Calculate target size while maintaining aspect ratio
        var targetSize = image.size
        if targetSize.width > maxImageSize || targetSize.height > maxImageSize {
            let scale = min(maxImageSize/targetSize.width, maxImageSize/targetSize.height)
            targetSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        }
        
        // 2. Calculate crop rect centered on face
        let faceCenterX = faceRect.midX
        let faceCenterY = faceRect.midY
        
        // Make crop rect square and centered on face
        let cropSize = min(targetSize.width, targetSize.height)
        var cropRect = CGRect(
            x: faceCenterX - cropSize/2,
            y: faceCenterY - cropSize/2,
            width: cropSize,
            height: cropSize
        )
        
        // Adjust if crop rect goes outside image bounds
        if cropRect.minX < 0 {
            cropRect.origin.x = 0
        }
        if cropRect.minY < 0 {
            cropRect.origin.y = 0
        }
        if cropRect.maxX > image.size.width {
            cropRect.origin.x = image.size.width - cropSize
        }
        if cropRect.maxY > image.size.height {
            cropRect.origin.y = image.size.height - cropSize
        }
        
        // 3. Create final image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cropSize, height: cropSize), false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw cropped portion
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            let croppedImage = UIImage(cgImage: cgImage)
            croppedImage.draw(in: CGRect(origin: .zero, size: CGSize(width: cropSize, height: cropSize)))
        } else {
            // Fallback to drawing the whole image if cropping fails
            image.draw(in: CGRect(origin: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y), size: image.size))
        }
        
        guard let processedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw SkinAnalysisError.imageProcessingError
        }
        
        return processedImage
    }
}

// MARK: - Preview Support
#if DEBUG
extension SkinAnalysisServiceImpl {
    /// Creates a mock response for preview and testing purposes
    public static func preview() -> SkinAnalysisModels.Response {
        return .preview
    }
}
#endif
#endif
