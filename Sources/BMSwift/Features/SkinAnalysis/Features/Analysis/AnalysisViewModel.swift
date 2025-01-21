#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit
import BMNetwork

// MARK: - View Model
@available(iOS 13.0, *)
@MainActor
public final class AnalysisViewModel: ObservableObject {
    // MARK: - State Enum
    public enum State {
        case idle
        case analyzing
        case success(SkinAnalysis.AnalysisResults)
        case failure(Error)
    }
    
    // MARK: Published Properties
    @Published private(set) var state: State = .idle
    
    // MARK: Private Properties
    private let analysisService: AnalysisService
    
    // MARK: Initialization
    public init(analysisService: AnalysisService = AnalysisServiceImpl()) {
        self.analysisService = analysisService
    }
    
    // MARK: Public Methods
    public func analyze(image: UIImage) async {
        state = .analyzing
        
        do {
            let results = try await analysisService.analyze(image: image)
            state = .success(results)
        } catch {
            state = .failure(error)
        }
    }
    
    public func reset() {
        state = .idle
    }
}
#endif
