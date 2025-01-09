#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    // Custom TextField States
    @State private var isEmailFocused: Bool = false
    @State private var isPasswordFocused: Bool = false
    @State private var isConfirmPasswordFocused: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var shouldDismiss: Bool = false
    
    public init() {}
    
    public var body: some View {
        Group {
            ZStack {
                AppColors.primaryBg
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        Text("註冊")
                            .font(.title)
                            .foregroundColor(AppColors.primary)
                            .padding(.top, 50)
                        
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
                                
                                TextField(viewModel.email.isEmpty ? "請輸入電子郵件" : "", text: $viewModel.email)
                                    .foregroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .padding(.leading, 8)
                                    .onTapGesture {
                                        isEmailFocused = true
                                        isPasswordFocused = false
                                        isConfirmPasswordFocused = false
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
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
                                    TextField(viewModel.password.isEmpty ? "請輸入密碼" : "", text: $viewModel.password)
                                        .foregroundColor(AppColors.primary)
                                        .textInputAutocapitalization(.never)
                                        .padding(.leading, 8)
                                } else {
                                    SecureField(viewModel.password.isEmpty ? "請輸入密碼" : "", text: $viewModel.password)
                                        .foregroundColor(AppColors.primary)
                                        .textInputAutocapitalization(.never)
                                        .padding(.leading, 8)
                                }
                                
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .onTapGesture {
                                isEmailFocused = false
                                isPasswordFocused = true
                                isConfirmPasswordFocused = false
                            }
                        }
                        
                        // Confirm Password Input
                        VStack(alignment: .leading, spacing: 4) {
                            if isConfirmPasswordFocused || !viewModel.confirmPassword.isEmpty {
                                Text("確認密碼")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(AppColors.primary)
                                
                                if isConfirmPasswordVisible {
                                    TextField(viewModel.confirmPassword.isEmpty ? "請再次輸入密碼" : "", text: $viewModel.confirmPassword)
                                        .foregroundColor(AppColors.primary)
                                        .textInputAutocapitalization(.never)
                                        .padding(.leading, 8)
                                } else {
                                    SecureField(viewModel.confirmPassword.isEmpty ? "請再次輸入密碼" : "", text: $viewModel.confirmPassword)
                                        .foregroundColor(AppColors.primary)
                                        .textInputAutocapitalization(.never)
                                        .padding(.leading, 8)
                                }
                                
                                Button(action: { isConfirmPasswordVisible.toggle() }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .onTapGesture {
                                isEmailFocused = false
                                isPasswordFocused = false
                                isConfirmPasswordFocused = true
                            }
                        }
                        
                        // Register Button
                        Button(action: {
                            Task {
                                await viewModel.register()
                                if viewModel.isRegistered {
                                    shouldDismiss = true
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("註冊")
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigate(to: LoginView(), when: $shouldDismiss, navigationStyle: .modal)
    }
}
#endif
