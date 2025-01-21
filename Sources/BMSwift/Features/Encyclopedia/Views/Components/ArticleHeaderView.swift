#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import BMNetwork

struct ArticleHeaderView: View {
    let info: ArticleDetailResponse.Info
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title section
            Text(info.bp_subsection_title)
                .font(.title2)
                .fontWeight(.bold)
                .bmForegroundColor(AppColors.primary)
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
                    .bmForegroundColor(AppColors.secondaryText)
            } icon: {
                Image(systemName: "eye.fill")
                    .bmForegroundColor(AppColors.primary)
            }
            
            // Like count
            Label {
                Text("\(info.likecount)")
                    .bmForegroundColor(AppColors.secondaryText)
            } icon: {
                Image(systemName: "heart.fill")
                    .bmForegroundColor(AppColors.primary)
            }
            
            Spacer()
            
            // Publication date
            Text(formattedDate)
                .font(.caption)
                .bmForegroundColor(AppColors.secondaryText)
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
