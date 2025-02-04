#if canImport(SwiftUI) && os(iOS)
import Foundation
import UIKit

@available(iOS 13.0, *)
public protocol SkinAnalysisService {
    func analyzeImage(_ image: UIImage) async throws -> AnalysisResults
}

@available(iOS 13.0, *)
public final class SkinAnalysisServiceImpl: SkinAnalysisService {
    private let networkClient: BMNetwork.NetworkClient
    
    public init(networkClient: BMNetwork.NetworkClient = .shared) {
        self.networkClient = networkClient
    }
    
    public func analyzeImage(_ image: UIImage) async throws -> AnalysisResults {
        // 1. Upload image and get URL
        let imageUrl = try await uploadImage(image)
        
        // 2. Create and send RapidAPI request
        let endpoint = SkinAnalysisEndpoints.AnalyzeEndpoint(imageUrl: imageUrl)
        let request = BMNetwork.APIRequest(endpoint: endpoint)
        
        // 3. Get and map response
        let response = try await networkClient.send(request)
        return mapResponse(response)
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        // TODO: Implement image upload to get a public URL
        // For testing, return a sample image URL
        return "https://upload.wikimedia.org/wikipedia/commons/8/83/Angelina_Jolie_at_the_launch_of_the_UK_initiative_on_preventing_sexual_violence_in_conflict%2C_29_May_2012_%28cropped%29.jpg"
    }
    
    private func mapResponse(_ response: SkinAnalysisResponse) -> AnalysisResults {
        // TODO: Map RapidAPI response to our AnalysisResults model
        return AnalysisResults(
            score: response.score,
            details: [
                .init(category: "膚質", score: response.skinQualityScore),
                .init(category: "色調", score: response.skinToneScore),
                .init(category: "彈性", score: response.skinElasticityScore)
            ],
            recommendations: response.recommendations
        )
    }
}
#endif