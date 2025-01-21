#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit
import Foundation
import BMNetwork

// MARK: - Dependencies Container
@available(iOS 13.0, *)
@MainActor
private struct Dependencies {
    let viewModel: SkinAnalysisViewModel
    
    init(token: String, service: AnalysisService) async {
        self.viewModel = SkinAnalysisViewModel(token: token, service: service)
    }
}

// MARK: - Coordinator
@available(iOS 13.0, *)
@MainActor
public final class SkinAnalysisCoordinator: ObservableObject {
    // MARK: - Properties
    private let dependencies: Dependencies
    
    // MARK: - Published State
    @Published private(set) var currentRoute: Route?
    
    // MARK: - Initialization
    public init(token: String, service: AnalysisService = AnalysisServiceImpl()) async {
        self.dependencies = await Dependencies(token: token, service: service)
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
        await dependencies.viewModel.analyze(image: image)
        
        switch dependencies.viewModel.state {
        case .success(let results):
            navigate(to: .results(results))
        case .error(let error):
            navigate(to: .error(error))
        default:
            break
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
            case (.camera, .camera):
                return true
            case (.analyzing, .analyzing):
                return true
            case (.results(let lhsResults), .results(let rhsResults)):
                return lhsResults.score == rhsResults.score
            case (.error, .error):
                return true
            default:
                return false
            }
        }
    }
}
#endif
