#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @FocusState private var focusedField: Field?
    @Binding var isPresented: Bool
    
    private enum Field {
        case email
    }
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            AppColors.primaryBg.swiftUIColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.15)
                        
                    titleSection
                    
                    ZStack(alignment: .top) {
                        emailSection
                        
                        if focusedField == .email || !viewModel.email.isEmpty {
                            Text("")
                                .font(.caption)
                                .bmForegroundColor(AppColors.lightText)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .offset(y: -20)
                        }
                    }
                    .animation(.easeInOut, value: focusedField == .email || !viewModel.email.isEmpty)
                    
                    buttonSection
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .toast(message: "成功發送郵件！", isPresented: .init(
            get: { 
                if case .success = viewModel.state { return true }
                return false
            },
            set: { _ in }
        ))
        .onChange(of: viewModel.state) { newState in
            if case .success = newState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isPresented = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("忘記密碼？")
                .font(.title)
                .bmForegroundColor(AppColors.primary)
            
            Text("請輸入您的電子郵件地址，我們將發送重置密碼的連結給您。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .bmForegroundColor(AppColors.lightText)
        }
    }
    
    @ViewBuilder
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope")
                    .bmForegroundColor(AppColors.primary)
                
                TextField("電子郵件", text: $viewModel.email)
                    .bmForegroundColor(AppColors.primary)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .bmFill(AppColors.secondaryBg.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .bmStroke(
                        focusedField == .email ? 
                        AppColors.primary : 
                        AppColors.primary.opacity(0.3),
                        lineWidth: 1
                    )
            )
            
            if case .error(_) = viewModel.state {
                Text("請輸入有效的電子郵件地址")
                    .bmForegroundColor(AppColors.error)
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.sendResetEmail()
                }
            }) {
                Group {
                    if case .loading = viewModel.state {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.lightText.swiftUIColor))
                    } else {
                        Text("驗證Email")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .primaryButtonStyle(isEnabled: !viewModel.email.isEmpty)
            .disabled(viewModel.state == .loading || viewModel.email.isEmpty)
            
            Button(action: { isPresented = false }) {
                Text("返回")
                    .font(.system(size: 17, weight: .semibold))
                    .bmForegroundColor(AppColors.primary)
            }
            
            if case .error(let error) = viewModel.state {
                Text(error.localizedDescription)
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
