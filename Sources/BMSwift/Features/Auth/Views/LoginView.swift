#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var showEncyclopedia = false
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @State private var isPasswordVisible: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var showRegister: Bool = false
    
    public init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBg.swiftUIColor
                    .ignoresSafeArea()
                
                loginFormView
            }
            .navigationBarHidden(true)
            .task {
                print("[LoginView] Checking authentication status...")
                await viewModel.checkAuthenticationStatus()
            }
            .onChange(of: viewModel.token) { newToken in
                print("[LoginView] Token changed: \(newToken != nil)")
                if newToken != nil {
                    print("[LoginView] Have token, showing encyclopedia")
                    showEncyclopedia = true
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(isPresented: $showForgotPassword)
        }
        .sheet(isPresented: $showRegister) {
            NavigationView {
                RegisterView(isPresented: $showRegister)
            }
        }
        .fullScreenCover(isPresented: $showEncyclopedia) {
            if let token = viewModel.token {
                NavigationView {
                    EncyclopediaView(isPresented: $showEncyclopedia, token: token)
                }
            }
        }
    }
    
    private var loginFormView: some View {
        ZStack {
            AppColors.primaryBg.swiftUIColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Title
                    Text("登入")
                        .font(.title)
                        .bmForegroundColor(AppColors.primary)
                        .padding(.bottom, -10)
                    
                    // Image
                    Image("LoginImage", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .padding(.bottom, 10)
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "envelope")
                                .bmForegroundColor(AppColors.primary)
                            
                            TextField("請輸入電子郵件", text: $viewModel.email)
                                .bmForegroundColor(AppColors.primary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .focused($isEmailFocused)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .bmFill(AppColors.secondaryBg.opacity(0.1))
                        )
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .bmForegroundColor(error == "成功登入" ? AppColors.success : AppColors.error)
                                .font(.caption)
                        }
                    }
                    
                    // Password Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "lock")
                                .bmForegroundColor(AppColors.primary)
                            
                            if isPasswordVisible {
                                TextField("請輸入密碼", text: $viewModel.password)
                                    .bmForegroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .focused($isPasswordFocused)
                            } else {
                                SecureField("請輸入密碼", text: $viewModel.password)
                                    .bmForegroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .focused($isPasswordFocused)
                            }
                            
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .bmForegroundColor(AppColors.primary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .bmFill(AppColors.secondaryBg.opacity(0.1))
                        )
                        
                        if viewModel.showPasswordWarning {
                            Text("密碼必須至少包含8個字符，包括大小寫字母")
                                .bmForegroundColor(AppColors.error)
                                .font(.caption)
                        }
                    }
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.white.swiftUIColor))
                        } else {
                            Text("登入")
                                .font(.headline)
                                .bmForegroundColor(AppColors.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .bmBackground(AppColors.primary)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                    
                    // Additional Options
                    HStack {
                        Button("忘記密碼?") {
                            showForgotPassword = true
                        }
                        .bmForegroundColor(AppColors.primary)
                        .padding(.top, -10)
                        
                        Spacer()
                        
                        Button("註冊") {
                            showRegister = true
                        }
                        .bmForegroundColor(AppColors.primary)
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
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
#endif