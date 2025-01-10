#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @State private var isPasswordVisible: Bool = false
    @State private var showForgotPassword: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoggedIn {
                    loggedInView
                } else {
                    loginFormView
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(isPresented: $showForgotPassword)
        }
    }
    
    private var loginFormView: some View {
        ZStack {
            AppColors.primaryBg
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 50)
                    
                    // Title
                    Text("登入")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                    
                    // Image
                    Image("SiteImage", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 20)
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(AppColors.primary)
                            
                            TextField("請輸入電子郵件", text: $viewModel.email)
                                .foregroundColor(AppColors.primary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .focused($isEmailFocused)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(AppColors.primary)
                                .padding(.leading, 4)
                            
                            if isPasswordVisible {
                                TextField("請輸入密碼", text: $viewModel.password)
                                    .foregroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .focused($isPasswordFocused)
                                    .padding(.leading, 4)
                            } else {
                                SecureField("請輸入密碼", text: $viewModel.password)
                                    .foregroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .focused($isPasswordFocused)
                                    .padding(.leading, 4)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    
                    // Forgot Password and Register buttons
                    HStack {
                        NavigationLink(destination: RegisterView()) {
                            Text("註冊")
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("忘記密碼？")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登入")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .onTapGesture {
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
                
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("登出")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
#endif
