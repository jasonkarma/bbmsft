#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct HTMLTextView: View {
    let htmlContent: String
    @State private var attributedText: AttributedString = AttributedString("")
    
    var body: some View {
        Text(attributedText)
            .task {
                Task {
                    await convertHTML()
                }
            }
    }
    
    private func convertHTML() async {
        guard let data = htmlContent.data(using: .utf8) else { return }
        
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let attributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
            
            var attributedStringResult = AttributedString(attributedString)
            
            // Apply styling
            attributedStringResult.foregroundColor = .primary
            attributedStringResult.font = .body
            
            await MainActor.run {
                self.attributedText = attributedStringResult
            }
        } catch {
            print("Error converting HTML: \(error)")
            await MainActor.run {
                self.attributedText = AttributedString(htmlContent)
            }
        }
    }
}
#endif
