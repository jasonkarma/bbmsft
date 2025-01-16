#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct ArticleDetailView: View {
    @StateObject var viewModel: ArticleDetailViewModel
    
    public init(viewModel: ArticleDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            if let article = viewModel.articleDetail {
                VStack(alignment: .leading, spacing: 16) {
                    // Article Info
                    Text(article.info.bp_subsection_title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                    
                    // Stats and Date
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                            Text("\(article.info.visit)")
                        }
                        .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                            Text("\(article.info.likecount)")
                        }
                        .foregroundColor(.gray)
                        
                        Text(article.info.bp_subsection_first_enabled_at)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .font(.caption)
                    
                    // Content
                    ArticleContentView(htmlContent: article.info.bp_subsection_intro)
                    
                    // Banner Image
                    if !article.info.name.isEmpty {
                        AsyncImage(url: URL(string: "https://wiki.kinglyrobot.com/media/beauty_content_banner_image/\(article.info.name)")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            case .failure(_):
                                Color.gray.opacity(0.3)
                                    .frame(height: 200)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Article Content Sections
                    ForEach(article.cnt, id: \.title) { content in
                        VStack(alignment: .leading, spacing: 8) {
                            if !content.title.isEmpty {
                                Text(content.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primary)
                            }
                            
                            ArticleContentView(htmlContent: content.cnt)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Keywords
                    if !article.keywords.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(article.keywords, id: \.bp_tag_id) { keyword in
                                    Text("#\(keyword.bp_hashtag)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Comments Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comments")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                        
                        ForEach(viewModel.comments, id: \.created_at) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.user_name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primary)
                                Text(comment.cnt)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Text(comment.created_at)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Comment Input
                        HStack {
                            TextField("Add a comment...", text: $viewModel.commentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Post") {
                                Task {
                                    await viewModel.submitComment()
                                }
                            }
                            .disabled(viewModel.commentText.isEmpty)
                        }
                    }
                    
                    // Suggested Articles
                    if !article.suggests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Articles")
                                .font(.headline)
                                .foregroundColor(AppColors.primary)
                            
                            ForEach(article.suggests, id: \.bp_subsection_id) { suggestion in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(suggestion.bp_subsection_title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.primary)
                                    Text(suggestion.bp_subsection_intro)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        Task {
                            await viewModel.likeArticle()
                        }
                    } label: {
                        Image(systemName: viewModel.articleDetail?.clientsAction.like == true ? "heart.fill" : "heart")
                    }
                    
                    Button {
                        Task {
                            await viewModel.keepArticle()
                        }
                    } label: {
                        Image(systemName: viewModel.articleDetail?.clientsAction.keep == true ? "bookmark.fill" : "bookmark")
                    }
                }
            }
        }
        .task {
            await viewModel.loadContent()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

struct ArticleContentView: View {
    let htmlContent: String
    
    private struct ContentItem: Identifiable {
        let id = UUID()
        enum ItemType {
            case text(String, isHeader: Bool = false)
            case image(URL)
        }
        let type: ItemType
    }
    
    @State private var contentItems: [ContentItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(contentItems) { item in
                switch item.type {
                case .text(let text, let isHeader):
                    Text(text)
                        .font(isHeader ? .callout : .body)
                        .fontWeight(isHeader ? .bold : .regular)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                case .image(let imageUrl):
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Color.gray
                                .opacity(0.3)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            processContent()
        }
    }
    
    private func decodeUnicode(_ text: String) -> String {
        let pattern = "\\\\u([0-9a-fA-F]{4})"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        
        var result = text
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches.reversed() {
            guard let hexRange = Range(match.range(at: 1), in: text),
                  let unicodeScalar = UInt32(text[hexRange], radix: 16),
                  let scalar = Unicode.Scalar(unicodeScalar) else { continue }
            
            let char = String(scalar)
            guard let matchRange = Range(match.range(at: 0), in: result) else { continue }
            result.replaceSubrange(matchRange, with: char)
        }
        
        return result
    }
    
    private func processContent() {
        var items: [ContentItem] = []
        let content = decodeUnicode(htmlContent)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Split content by image tags and process each part
        let parts = content.components(separatedBy: "<img")
        
        for (index, part) in parts.enumerated() {
            if index == 0 {
                // Process first part (before any images)
                processPart(part, into: &items)
            } else {
                // Process image and remaining text
                let subParts = part.components(separatedBy: ">")
                if subParts.count >= 2 {
                    // Extract image URL
                    if let srcMatch = subParts[0].range(of: "src=\"([^\"]+)\"", options: .regularExpression),
                       let urlString = String(subParts[0][srcMatch]).components(separatedBy: "\"").dropFirst().first,
                       let url = URL(string: urlString) {
                        items.append(ContentItem(type: .image(url)))
                    }
                    
                    // Process remaining text
                    let remainingText = subParts.dropFirst().joined(separator: ">")
                    processPart(remainingText, into: &items)
                }
            }
        }
        
        contentItems = items
    }
    
    private func processPart(_ text: String, into items: inout [ContentItem]) {
        var content = text
        
        // First, extract and process headers while maintaining their position
        var currentPosition = content.startIndex
        while let headerStartRange = content[currentPosition...].range(of: "<h4>"),
              let headerEndRange = content[headerStartRange.upperBound...].range(of: "</h4>") {
            
            // Add text before header if any
            let textBeforeHeader = String(content[currentPosition..<headerStartRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !textBeforeHeader.isEmpty {
                let processedText = processText(textBeforeHeader)
                if !processedText.isEmpty {
                    items.append(ContentItem(type: .text(processedText)))
                }
            }
            
            // Add header
            let headerText = String(content[headerStartRange.upperBound..<headerEndRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !headerText.isEmpty {
                items.append(ContentItem(type: .text(headerText, isHeader: true)))
            }
            
            currentPosition = headerEndRange.upperBound
        }
        
        // Add remaining text after last header
        let remainingText = String(content[currentPosition...])
        let processedText = processText(remainingText)
        if !processedText.isEmpty {
            items.append(ContentItem(type: .text(processedText)))
        }
    }
    
    private func processText(_ text: String) -> String {
        text.replacingOccurrences(of: "<body[^>]*>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "</body>", with: "")
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "\n")
            .replacingOccurrences(of: "<div>", with: "")
            .replacingOccurrences(of: "</div>", with: "\n")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\\s*\n\\s*", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct HTMLTextView: View {
    let htmlContent: String
    @State private var attributedText: AttributedString = AttributedString("")
    
    var body: some View {
        Text(attributedText)
            .onAppear {
                parseHTML()
            }
    }
    
    private func parseHTML() {
        // Process HTML content
        let processedContent = htmlContent
            .replacingOccurrences(of: "<body[^>]*>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "</body>", with: "")
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<div", with: "<p")
            .replacingOccurrences(of: "</div>", with: "</p>")
            .replacingOccurrences(of: "&nbsp;", with: " ")
        
        // Convert to attributed string with all styling preserved
        if let data = processedContent.data(using: .utf8),
           let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
           ) {
            attributedText = AttributedString(attributedString)
        } else {
            // Fallback: display raw text if HTML parsing fails
            attributedText = AttributedString(processedContent
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
#endif
