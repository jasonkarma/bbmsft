#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct EncyclopediaView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            // Content area
            ZStack {
                AppColors.primaryBg.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Voice command area
                    HStack {
                        Text("取得美容百科文章資料 10 篇")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Voice command functionality will be implemented later
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().stroke(Color.white, lineWidth: 2))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    
                    // Smart device stats area
                    VStack(spacing: 8) {
                        // Bar chart container
                        VStack(alignment: .leading, spacing: 0) {
                            // Chart header
                            HStack {
                                Text("TEST BAR VIEW")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Chart area
                            HStack(spacing: 0) {
                                // Y-axis values
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text("200")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text("100")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                    Spacer()
                                    Text("0")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                }
                                .frame(width: 25)
                                .padding(.leading)
                                .padding(.trailing, 4)
                                
                                // Bars
                                HStack(alignment: .bottom, spacing: 0) {
                                    ForEach(0..<4) { index in
                                        VStack(spacing: 2) {
                                            Rectangle()
                                                .fill(Color.yellow.opacity(0.8))
                                                .frame(width: 16, height: CGFloat.random(in: 30...65))
                                            
                                            Text("\(index * 6)")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white)
                                        }
                                        Spacer(minLength: 50)
                                    }
                                    VStack(spacing: 2) {
                                        Rectangle()
                                            .fill(Color.yellow.opacity(0.8))
                                            .frame(width: 16, height: CGFloat.random(in: 30...65))
                                        
                                        Text("24")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.trailing)
                                }
                            }
                            .frame(height: 80)
                            .padding(.horizontal, -30)
                        }
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.blue)
                            Text("心率")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                            Text("步數")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("消耗")
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 12))
                    }
                    .padding(.horizontal)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // Bottom navigation
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 2) {
                            Group {
                                switch index {
                                case 0:
                                    Image(systemName: "star.fill")
                                        .overlay(
                                            HStack(spacing: -4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 8))
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 8))
                                            }
                                        )
                                case 1:
                                    Image(systemName: "book.fill")
                                case 2:
                                    ZStack {
                                        Image(systemName: "iphone")
                                        Image(systemName: "applewatch")
                                            .offset(x: 4, y: 0)
                                    }
                                case 3:
                                    Image(systemName: "bell.fill")
                                default:
                                    EmptyView()
                                }
                            }
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                            
                            Text(tabTitle(for: index))
                                .font(.system(size: 12))
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.bottom, -10)
            .background(Color.black.opacity(0.3))
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "AI功能"
        case 1: return "美容百科"
        case 2: return "裝置"
        case 3: return "AI提醒"
        default: return ""
        }
    }
}

#if DEBUG
struct EncyclopediaView_Previews: PreviewProvider {
    static var previews: some View {
        EncyclopediaView()
    }
}
#endif
#endif
