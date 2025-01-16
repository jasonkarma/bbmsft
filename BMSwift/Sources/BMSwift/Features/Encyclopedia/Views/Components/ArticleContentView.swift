#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleContentView: View {
    let htmlContent: String
    
    private struct ContentItem: Identifiable {
        let id = UUID()
        let content: String
        let type: ContentType
        
        enum ContentType {
            case header
            case text
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let items = processContent(htmlContent)
            ForEach(items) { item in
                switch item.type {
                case .header:
                    Text(item.content)
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                case .text:
                    HTMLTextView(htmlContent: item.content)
                }
            }
        }
    }
    
    private func processContent(_ content: String) -> [ContentItem] {
        var items: [ContentItem] = []
        processPart(content, into: &items)
        return items
    }
    
    private func processPart(_ text: String, into items: inout [ContentItem]) {
        let content = text
        
        // First, extract and process headers while maintaining their position
        var currentPosition = content.startIndex
        while let headerRange = content[currentPosition...].range(of: "##[^#\\n]+", options: .regularExpression) {
            // Add text before header if any
            if headerRange.lowerBound > currentPosition {
                let textBefore = String(content[currentPosition..<headerRange.lowerBound])
                if !textBefore.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    items.append(ContentItem(content: textBefore, type: .text))
                }
            }
            
            // Add header
            var headerText = String(content[headerRange])
            headerText = headerText.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            headerText = headerText.trimmingCharacters(in: .whitespaces)
            items.append(ContentItem(content: headerText, type: .header))
            
            currentPosition = headerRange.upperBound
        }
        
        // Add remaining text if any
        if currentPosition < content.endIndex {
            let remainingText = String(content[currentPosition...])
            if !remainingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(ContentItem(content: remainingText, type: .text))
            }
        }
    }
}
#endif
