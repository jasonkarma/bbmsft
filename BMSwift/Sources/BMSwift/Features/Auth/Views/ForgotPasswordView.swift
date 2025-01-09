#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @State private var isEmailFocused: Bool = false
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            AppColors.primaryBg
                .ignoresSafeArea()
            
            ScrollView {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.15) // Add space at the top
                
                VStack(spacing: 30) {
                    Text("忘記密碼？")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                    
                    Text("請輸入您的電子郵件地址，我們將發送重置密碼的連結給您。")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
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
                            
                            TextField("電子郵件", text: $viewModel.email)
                                .foregroundColor(AppColors.primary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .onTapGesture {
                                    isEmailFocused = true
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
                    .padding(.horizontal, 30)
                    
                    // Error message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(AppColors.error)
                            .font(.caption)
                    }
                    
                    // Success message
                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(AppColors.primary)
                            .font(.caption)
                    }
                    
                    // Verify Email button
                    Button(action: {
                        Task {
                            await viewModel.sendResetEmail()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("驗證Email")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .primaryButtonStyle(isEnabled: !viewModel.email.isEmpty)
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty)
                    .padding(.horizontal, 30)
                    
                    // Return button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("返回")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.15) // Add space at the bottom
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            isEmailFocused = false
        }
    }
}

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 13.0, *) {
            ForgotPasswordView(isPresented: .constant(true))
        }
    }
}
#endif
#endif
