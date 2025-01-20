#if canImport(SwiftUI) && os(iOS)
import SwiftUI

/// A view that provides skin analysis functionality.
@available(iOS 13.0, *)
public struct SkinAnalysisView: View {
    // MARK: - Properties
    @StateObject private var viewModel: AnalysisViewModel
    
    // MARK: - Initialization
    public init() {
        _viewModel = StateObject(wrappedValue: AnalysisViewModel())
    }
    
    // MARK: - Body
    public var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                CameraScannerView { image in
                    Task {
                        await viewModel.analyze(image: image)
                    }
                }
                
            case .analyzing:
                AnalysisLoadingView()
                
            case .success(let results):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("分析結果")
                            .font(.title)
                            .padding(.horizontal)
                        
                        Text("整體分數: \(results.score)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(results.details, id: \.category) { detail in
                            HStack {
                                Text(detail.category)
                                Spacer()
                                Text("\(detail.score)")
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("建議")
                            .font(.headline)
                            .padding(.top)
                            .padding(.horizontal)
                        
                        ForEach(results.recommendations, id: \.self) { recommendation in
                            Text("• \(recommendation)")
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
            case .failure(let error):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("重試") {
                        viewModel.reset()
                    }
                }
            }
        }
        .navigationBarTitle("皮膚分析", displayMode: .large)
    }
}

// MARK: - Preview Provider
@available(iOS 13.0, *)
struct SkinAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        SkinAnalysisView()
    }
}
#endif
