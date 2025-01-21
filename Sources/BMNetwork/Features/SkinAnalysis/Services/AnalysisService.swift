#if canImport(SwiftUI) && os(iOS)
import UIKit

// MARK: - Analysis Service Implementation
@available(iOS 13.0, *)
public actor AnalysisServiceImpl: AnalysisService {
    // MARK: - Properties
    private let networkClient: BMNetworkcl.NetworkClient
    
    // MARK: - Initialization
    public init(networkClient: BMNetworkcl.NetworkClient = .init()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    public func analyze(image: UIImage) async throws -> SkinAnalysis.AnalysisResults {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BMNetwork.APIError.invalidData
        }
        
        let endpoint = SkinAnalysisEndpoints.Check(imageData: imageData)
        let request = BMNetwork.APIRequest(endpoint: endpoint)
        
        let response: SkinAnalysisResponse = try await networkClient.send(request)
        return response.toDomain()
    }
}

// MARK: - Mock Service
@available(iOS 13.0, *)
public actor MockAnalysisService: AnalysisService {
    public init() {}
    
    public func analyze(image: UIImage) async throws -> SkinAnalysis.AnalysisResults {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return .mock
    }
}
#endif
