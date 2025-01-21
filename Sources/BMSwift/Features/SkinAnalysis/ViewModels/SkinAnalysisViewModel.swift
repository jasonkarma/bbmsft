import Foundation
import SwiftUI
import BMNetwork

@MainActor
final class SkinAnalysisViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var state: ViewState = .idle
    
    // MARK: - Dependencies
    private let service: AnalysisService
    private let token: String
    
    // MARK: - Initialization
    init(token: String, service: AnalysisService = AnalysisServiceImpl()) {
        self.token = token
        self.service = service
    }
    
    // MARK: - Analysis Methods
    func analyze(image: UIImage) async {
        state = .analyzing
        
        do {
            let results = try await service.analyze(image: image)
            state = .success(results)
        } catch {
            state = .error(error)
        }
    }
}

// MARK: - View State
extension SkinAnalysisViewModel {
    enum ViewState {
        case idle
        case analyzing
        case success(SkinAnalysis.AnalysisResults)
        case error(Error)
    }
}
