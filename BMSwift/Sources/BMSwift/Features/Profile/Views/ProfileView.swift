#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Binding var isPresented: Bool
    
    public init(token: String, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(token: token))
        _isPresented = isPresented
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .bmForegroundColor(AppColors.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bmForegroundColor(AppColors.primary)
        }
    }
    
    public var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
                    .onAppear {
                        Task {
                            await viewModel.loadProfile()
                        }
                    }
                
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                
            case .error(let error):
                VStack(spacing: 16) {
                    Text("載入失敗")
                        .font(.headline)
                        .bmForegroundColor(AppColors.warning)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .bmForegroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Button("重試") {
                        Task {
                            await viewModel.loadProfile()
                        }
                    }
                }
                
            case .loaded(let response):
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            if let mediaName = response.user.mediaName {
                                AsyncImage(url: URL(string: "https://wiki.kinglyrobot.com/storage/\(mediaName)")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .bmForegroundColor(AppColors.primary)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .bmForegroundColor(AppColors.primary)
                            }
                            
                            Text(response.user.username)
                                .font(.title2)
                                .bmForegroundColor(AppColors.primaryText)
                            
                            Text(response.user.email)
                                .font(.subheadline)
                                .bmForegroundColor(AppColors.secondaryText)
                        }
                        
                        VStack(spacing: 16) {
                            infoRow(title: "姓名", value: response.user.realname ?? "未設定")
                            infoRow(title: "電話", value: response.user.phone.map(String.init) ?? "未設定")
                            infoRow(title: "地區", value: response.user.addr ?? "未設定")
                            infoRow(title: "生日", value: response.user.birth ?? "未設定")
                            infoRow(title: "身高", value: response.user.height.map { "\($0) cm" } ?? "未設定")
                            infoRow(title: "體重", value: response.user.weight.map { "\($0) kg" } ?? "未設定")
                            infoRow(title: "性別", value: response.user.sexString)
                            infoRow(title: "血型", value: response.user.bloodTypeString)
                        }
                        .padding()
                        .background(AppColors.black.swiftUIColor.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.logout()
                            isPresented = false
                        }) {
                            Text("登出")
                                .font(.headline)
                                .bmForegroundColor(AppColors.warning)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.black.swiftUIColor.opacity(0.5))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("個人資料")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(token: "preview_token", isPresented: .constant(true))
        }
    }
}
#endif
#endif
