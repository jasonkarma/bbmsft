#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Binding var isPresented: Bool
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?
    @State private var showToast = false
    @State private var toastMessage = ""
    
    private enum Field {
        case email, username, password, confirmPassword
    }
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBg.swiftUIColor
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Title
                        Text("註冊")
                            .font(.title)
                            .bmForegroundColor(AppColors.primary)
                            .padding(.bottom, -10)
                        
                        // Email Field
                        inputField(
                            icon: "envelope",
                            placeholder: "電郵地址",
                            text: $viewModel.email,
                            field: .email,
                            keyboardType: .emailAddress
                        )
                        
                        // Username Field
                        inputField(
                            icon: "person",
                            placeholder: "用戶名稱",
                            text: $viewModel.username,
                            field: .username
                        )
                        
                        // Password Field
                        inputField(
                            icon: "lock",
                            placeholder: "密碼",
                            text: $viewModel.password,
                            field: .password,
                            isSecure: !isPasswordVisible,
                            showPasswordToggle: true
                        )
                        
                        // Confirm Password Field
                        inputField(
                            icon: "lock",
                            placeholder: "確認密碼",
                            text: $viewModel.confirmPassword,
                            field: .confirmPassword,
                            isSecure: !isPasswordVisible,
                            showPasswordToggle: true
                        )
                        
                        // Register Button
                        Button {
                            Task {
                                await viewModel.register()
                            }
                        } label: {
                            HStack {
                                if case .loading = viewModel.state {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("註冊")
                                        .bmForegroundColor(AppColors.white)
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .bmBackground(AppColors.primary)
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
            .onChange(of: viewModel.state) { state in
                if case .success(let response) = state, response.message != nil {
                    showToast = true
                    toastMessage = "註冊成功！"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isPresented = false
                    }
                }
            }
            .toast(message: toastMessage, isPresented: $showToast)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .bmForegroundColor(AppColors.primary)
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                        .font(.headline)
                        .bmForegroundColor(AppColors.primary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        isSecure: Bool = false,
        showPasswordToggle: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .bmForegroundColor(AppColors.primary)
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: text)
                    } else {
                        TextField(placeholder, text: text)
                    }
                }
                .bmForegroundColor(AppColors.primary)
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
                
                if showPasswordToggle {
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .bmForegroundColor(AppColors.primary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .bmFill(AppColors.secondaryBg.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .bmStroke(
                        focusedField == field ? 
                        AppColors.primary : 
                        AppColors.primary.opacity(0.3),
                        lineWidth: 1
                    )
            )
            
            if case .error(let errorMessage) = viewModel.state, focusedField == field {
                Text(errorMessage)
                    .bmForegroundColor(AppColors.error)
                    .font(.caption)
            }
        }
    }
}
#endif
