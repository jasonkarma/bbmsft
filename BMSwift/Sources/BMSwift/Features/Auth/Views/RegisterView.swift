#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Binding var isPresented: Bool
    @State private var isPasswordVisible = false
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            AppColors.primaryBg
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 50)
                        
                    Text("註冊")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                    
                    // Nickname Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(AppColors.primary)
                            TextField("請輸入暱稱", text: $viewModel.username)
                                .textContentType(.username)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    
                    // Email Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppColors.primary)
                                .padding(.leading, -2)
                            TextField("請輸入電子郵件", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(.leading, -3)
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
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppColors.primary)
                                .padding(.leading, 3)
                            Group {
                                if isPasswordVisible {
                                    TextField("請輸入密碼", text: $viewModel.password)
                                        .padding(.leading, 1)
                                        .onChange(of: viewModel.password) { _ in
                                            viewModel.validatePasswordInput()
                                        }
                                } else {
                                    SecureField("請輸入密碼", text: $viewModel.password)
                                        .padding(.leading, 1)
                                        .onChange(of: viewModel.password) { _ in
                                            viewModel.validatePasswordInput()
                                        }
                                }
                            }
                            .textContentType(.newPassword)
                            
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
                        
                        if viewModel.showPasswordWarning {
                            Text("密碼需大於8字．且有大小寫英文")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.register()
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("確認") {
                viewModel.dismissAlert()
                isPresented = false
            }
        }
        .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                isPresented = false
            }
        }
    }
}
#endif
