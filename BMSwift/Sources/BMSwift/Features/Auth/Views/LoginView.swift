#if canImport(SwiftUI) && os(iOS)
import SwiftUI

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
        VStack(spacing: 20) {
            Text("登入")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            CustomTextField(
                text: $viewModel.email,
                placeholder: "電子郵件",
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never
            )
            
            CustomTextField(
                text: $viewModel.password,
                placeholder: "密碼",
                isSecure: true,
                textInputAutocapitalization: .never
            )
            
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                Text("登入")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
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
