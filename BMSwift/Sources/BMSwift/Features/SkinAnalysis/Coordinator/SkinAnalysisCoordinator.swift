#if canImport(SwiftUI) && os(iOS)
import SwiftUI

// MARK: - Dependencies Container
@available(iOS 13.0, *)
public struct Dependencies {
    let analysisService: AnalysisService
    
    public init(analysisService: AnalysisService = AnalysisServiceImpl()) {
        self.analysisService = analysisService
    }
}

// MARK: - Coordinator
@available(iOS 13.0, *)
@MainActor
public final class SkinAnalysisCoordinator: ObservableObject {
    // MARK: - Dependencies
    private let dependencies: Dependencies
    
    // MARK: - Published State
    @Published private(set) var currentRoute: Route?
    
    // MARK: - Initialization
    public init(dependencies: Dependencies = Dependencies()) {
        self.dependencies = dependencies
    }
    
    // MARK: - Navigation
    public func start() {
        navigate(to: .camera)
    }
    
    public func navigate(to route: Route) {
        currentRoute = route
    }
    
    // MARK: - Actions
    public func handleCapturedImage(_ image: UIImage) async {
        navigate(to: .analyzing)
        
        do {
            let results = try await dependencies.analysisService.analyze(image: image)
            navigate(to: .results(results))
        } catch {
            navigate(to: .error(error))
        }
    }
}

// MARK: - Route
@available(iOS 13.0, *)
extension SkinAnalysisCoordinator {
    public enum Route: Equatable {
        case camera
        case analyzing
        case results(SkinAnalysis.AnalysisResults)
        case error(Error)
        
        public static func == (lhs: Route, rhs: Route) -> Bool {
            switch (lhs, rhs) {
            case (.camera, .camera),
                 (.analyzing, .analyzing):
                return true
            case let (.results(lhsResults), .results(rhsResults)):
                return lhsResults.score == rhsResults.score
            case (.error, .error):
                // Note: Errors are not typically Equatable, so we just compare their presence
                return true
            default:
                return false
            }
        }
    }
}
#endif
