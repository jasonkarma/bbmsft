#if canImport(SwiftUI) && os(iOS)
import SwiftUI

/// BMSwift - Components
/// Custom text field with consistent styling and behavior
///
/// Dependencies:
/// - SwiftUI: Primary UI framework
/// - Theme: AppColors for styling
public struct CustomTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType
    private let textInputAutocapitalization: TextInputAutocapitalization
    
    public init(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textInputAutocapitalization = textInputAutocapitalization
    }
    
    public var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .keyboardType(keyboardType)
        .textInputAutocapitalization(textInputAutocapitalization)
        .autocorrectionDisabled(true)
        .padding(.horizontal)
    }
}

#if DEBUG
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomTextField(
                text: .constant(""),
                placeholder: "一般輸入",
                textInputAutocapitalization: .sentences
            )
            
            CustomTextField(
                text: .constant(""),
                placeholder: "電子郵件",
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never
            )
            
            CustomTextField(
                text: .constant(""),
                placeholder: "密碼",
                isSecure: true,
                textInputAutocapitalization: .never
            )
        }
        .padding()
    }
}
#endif
#endif
