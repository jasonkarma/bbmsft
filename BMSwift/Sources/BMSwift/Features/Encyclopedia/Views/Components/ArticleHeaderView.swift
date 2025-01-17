#if canImport(SwiftUI) && os(iOS)
import SwiftUI

struct ArticleHeaderView: View {
    let info: ArticleDetailResponse.Info
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title section
            Text(info.bp_subsection_title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Stats section
            statsSection
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            // View count
            Label {
                Text("\(info.visit)")
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "eye.fill")
                    .foregroundColor(.blue)
            }
            
            // Like count
            Label {
                Text("\(info.likecount)")
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            // Publication date
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: info.bp_subsection_first_enabled_at) {
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        }
        return info.bp_subsection_first_enabled_at
    }
}
#endif
