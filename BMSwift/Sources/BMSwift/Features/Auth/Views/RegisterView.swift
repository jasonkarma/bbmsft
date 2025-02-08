#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Binding var isPresented: Bool
    @State private var isPasswordVisible = false
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    // Email Field
                    VStack(alignment: .leading) {
                        Text("電郵地址")
                            .font(.subheadline)
                        TextField("", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // Username Field
                    VStack(alignment: .leading) {
                        Text("用戶名稱")
                            .font(.subheadline)
                        TextField("", text: $viewModel.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading) {
                        Text("密碼")
                            .font(.subheadline)
                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $viewModel.password)
                                } else {
                                    SecureField("", text: $viewModel.password)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.newPassword)
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading) {
                        Text("確認密碼")
                            .font(.subheadline)
                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    TextField("", text: $viewModel.confirmPassword)
                                } else {
                                    SecureField("", text: $viewModel.confirmPassword)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.newPassword)
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    
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
                .padding()
            }
            .onChange(of: viewModel.state) { state in
                if case .success = state {
                    isPresented = false
                }
            }
            .navigationBarTitle("註冊", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
            })
        }
    }
}
#endif
