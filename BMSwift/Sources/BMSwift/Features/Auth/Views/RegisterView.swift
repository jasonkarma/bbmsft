#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    // Custom TextField States
    @State private var isUsernameFocused: Bool = false
    @State private var isEmailFocused: Bool = false
    @State private var isPasswordFocused: Bool = false
    @State private var isPasswordVisible: Bool = false
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
                        
                        // Username Input
                        VStack(alignment: .leading, spacing: 4) {
                            if isUsernameFocused || !viewModel.username.isEmpty {
                                Text("暱稱")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                
                                TextField(viewModel.username.isEmpty ? "請輸入暱稱" : "", text: $viewModel.username)
                                    .foregroundColor(AppColors.primary)
                                    .textInputAutocapitalization(.never)
                                    .padding(.leading, 8)
                                    .onTapGesture {
                                        isUsernameFocused = true
                                        isEmailFocused = false
                                        isPasswordFocused = false
                                    }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isUsernameFocused ? AppColors.thirdBg : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isUsernameFocused ? AppColors.primary : AppColors.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .animation(.easeInOut, value: isUsernameFocused)
                        
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
                                        isUsernameFocused = false
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
                                
                                Group {
                                    if isPasswordVisible {
                                        TextField(viewModel.password.isEmpty ? "請輸入密碼" : "", text: $viewModel.password)
                                    } else {
                                        SecureField(viewModel.password.isEmpty ? "請輸入密碼" : "", text: $viewModel.password)
                                    }
                                }
                                .foregroundColor(AppColors.primary)
                                .textInputAutocapitalization(.never)
                                .padding(.leading, 8)
                                
                                Button(action: {
                                    withAnimation {
                                        isPasswordVisible.toggle()
                                    }
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
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
                                isUsernameFocused = false
                                isEmailFocused = false
                            }
                            
                            if !viewModel.isPasswordValid && !viewModel.password.isEmpty {
                                Text("密碼必須大於8字，且有大小寫英文")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 4)
                            }
                        }
                        .animation(.easeInOut, value: isPasswordFocused)
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        
                        // Register Button
                        Button(action: {
                            Task {
                                await viewModel.register()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("確認註冊")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .primaryButtonStyle(isEnabled: viewModel.isPasswordValid && !viewModel.username.isEmpty && !viewModel.email.isEmpty)
                        .disabled(!viewModel.isPasswordValid || viewModel.username.isEmpty || viewModel.email.isEmpty || viewModel.isLoading)
                        .padding(.top, 30)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                isUsernameFocused = false
                isEmailFocused = false
                isPasswordFocused = false
            }
            .onChange(of: viewModel.isRegistered) { isRegistered in
                if isRegistered {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)  // Wait for 1 second
                        shouldDismiss = true
                    }
                }
            }
        }
        .navigate(to: LoginView(), when: $shouldDismiss, navigationStyle: .modal)
    }
}
#endif
