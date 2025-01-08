#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit

/// BMSwift - Auth Feature
/// Login view implementation with email and password fields
///
/// Dependencies:
/// - SwiftUI: Primary UI framework
/// - NetworkModels: Login request/response models
public struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    public init() {}
    
    public var body: some View {
        Group {
            if viewModel.isLoggedIn {
                loggedInView
            } else {
                loginFormView
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var loginFormView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("登入")
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                CustomTextField(
                    text: $viewModel.email,
                    placeholder: "電子郵件",
                    keyboardType: .emailAddress,
                    autocapitalizationType: .none
                )
                
                CustomTextField(
                    text: $viewModel.password,
                    placeholder: "密碼",
                    isSecure: true,
                    keyboardType: .default,
                    autocapitalizationType: .none
                )
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
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
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal)
        }
    }
    
    private var loggedInView: some View {
        VStack(spacing: 20) {
            Text("已登入")
                .font(.title)
            
            if viewModel.isFirstLogin {
                Text("歡迎新用戶！")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Button(action: {
                Task {
                    await viewModel.logout()
                }
            }) {
                Text("登出")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
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
