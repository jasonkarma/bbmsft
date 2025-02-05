import SwiftUI
import BMSwift

struct SkinAnalysisTestView: View {
    @State private var showSkinAnalysis = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Skin Analysis Test")
                .font(.title)
            
            Button(action: {
                showSkinAnalysis = true
            }) {
                Text("Start Skin Analysis")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showSkinAnalysis) {
            SkinAnalysisView(isPresented: $showSkinAnalysis)
        }
    }
}

#Preview {
    SkinAnalysisTestView()
}
