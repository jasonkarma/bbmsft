#if canImport(SwiftUI) && os(iOS)
import SwiftUI

/// BMSwift - Auth Feature
/// Login view implementation with email and password fields
///
/// Dependencies:
/// - SwiftUI: Primary UI framework
/// - NetworkModels: Login request/response models
public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    // Custom TextField States
    @State private var isEmailFocused: Bool = false
    @State private var isPasswordFocused: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    private let logoImage = UIImage(contentsOfFile: "/Users/karma/Desktop/bbmsft/siteLogob.png")
    
    public init() {}
    
    public var body: some View {
        Group {
            if viewModel.isLoggedIn {
                loggedInView
            } else {
                loginFormView
            }
        }
    }
    
    private var loginFormView: some View {
        ZStack {
            // Background
            AppColors.primaryBg
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("登入")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                        .padding(.top, 50)
                    
                    // Logo
                    if let logo = logoImage {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 30)
                    }
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        if isEmailFocused || !viewModel.email.isEmpty {
                            Text("電子郵件")
                                .foregroundColor(.white)
                                .font(.caption)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(AppColors.primary)
                            
                            TextField(viewModel.email.isEmpty ? "電子郵件" : "", text: $viewModel.email)
                                .foregroundColor(AppColors.primary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .onTapGesture {
                                    isEmailFocused = true
                                    isPasswordFocused = false
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isEmailFocused ? AppColors.thirdBg : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isEmailFocused ? AppColors.primary : AppColors.primary.opacity(0.3), lineWidth: 1)
                        )
                        
                        if isEmailFocused {
                            Text("請輸入電子郵件")
                                .foregroundColor(.white)
                                .font(.caption)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: isEmailFocused)
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 4) {
                        if isPasswordFocused || !viewModel.password.isEmpty {
                            Text("密碼")
                                .foregroundColor(.white)
                                .font(.caption)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(AppColors.primary)
                            
                            if isPasswordVisible {
                                TextField(viewModel.password.isEmpty ? "密碼" : "", text: $viewModel.password)
                                    .foregroundColor(AppColors.primary)
                            } else {
                                SecureField(viewModel.password.isEmpty ? "密碼" : "", text: $viewModel.password)
                                    .foregroundColor(AppColors.primary)
                            }
                            
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isPasswordFocused ? AppColors.thirdBg : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isPasswordFocused ? AppColors.primary : AppColors.primary.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            isPasswordFocused = true
                            isEmailFocused = false
                        }
                        
                        if isPasswordFocused {
                            Text("請輸入密碼")
                                .foregroundColor(.white)
                                .font(.caption)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: isPasswordFocused)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(AppColors.error)
                            .font(.caption)
                    }
                    
                    // Login button
                    Button(action: {
                        hideKeyboard()
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登入")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 30)
            }
        }
        .onTapGesture {
            hideKeyboard()
            isEmailFocused = false
            isPasswordFocused = false
        }
    }
    
    private var loggedInView: some View {
        ZStack {
            AppColors.primaryBg
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("登入成功")
                    .font(.title)
                    .foregroundColor(AppColors.primary)
                
                if viewModel.isFirstLogin {
                    Text("歡迎新用戶！")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: {
                    Task {
                        await viewModel.logout()
                    }
                }) {
                    Text("登出")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.error)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDisplayName("Login Screen")
        
        LoginView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Login Screen (Dark)")
        
        LoginView()
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE")
        
        LoginView()
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iPhone 14 Pro Max")
    }
}
#endif

#endif
