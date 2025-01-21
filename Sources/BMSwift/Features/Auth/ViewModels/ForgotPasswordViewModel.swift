#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import Combine

@available(iOS 13.0, *)
public class ForgotPasswordViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isResetEmailSent: Bool = false
    @Published public var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $email
            .map { $0.isEmpty }
            .assign(to: \.isEmailEmpty, on: self)
            .store(in: &cancellables)
    }
    
    @Published private(set) var isEmailEmpty: Bool = true
    
    public var isValidEmail: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    public func sendResetEmail() async {
        guard isValidEmail else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implement actual reset email logic
        isResetEmailSent = true
        isLoading = false
    }
}
#endif
