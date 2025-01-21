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
            AppColors.primaryBg.swiftUIColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    emailSection
                    buttonSection
                }
                .padding(.horizontal, 24)
            }
        }
        .toast(message: "重置密碼郵件已發送！", isPresented: $viewModel.isResetEmailSent)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("忘記密碼？")
                .font(.title)
                .bmForegroundColor(AppColors.lightText)
            
            Text("請輸入您的電子郵件地址，我們將發送重置密碼的連結給您。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .bmForegroundColor(AppColors.lightText)
        }
    }
    
    @ViewBuilder
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEmailFocused || !viewModel.email.isEmpty {
                Text("電子郵件")
                    .font(.caption)
                    .bmForegroundColor(AppColors.lightText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            HStack {
                Image(systemName: "envelope")
                    .bmForegroundColor(AppColors.primary)
                
                TextField("電子郵件", text: $viewModel.email)
                    .bmForegroundColor(AppColors.primary)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .onTapGesture {
                        isEmailFocused = true
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .bmFill(isEmailFocused ? AppColors.thirdBg : BMColor.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .bmStroke(
                        isEmailFocused ? 
                        AppColors.primary : 
                        AppColors.primary.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .animation(.easeInOut, value: isEmailFocused)
    }
    
    @ViewBuilder
    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.sendResetEmail()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.lightText.swiftUIColor))
                } else {
                    Text("驗證Email")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .primaryButtonStyle(isEnabled: viewModel.isValidEmail)
            .disabled(viewModel.isLoading || !viewModel.isValidEmail)
            
            Button(action: { isPresented = false }) {
                Text("返回")
                    .font(.system(size: 17, weight: .semibold))
                    .bmForegroundColor(AppColors.primary)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .bmForegroundColor(AppColors.error)
                    .padding(.top, 8)
            }
        }
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(isPresented: .constant(true))
    }
}
#endif
#endif
