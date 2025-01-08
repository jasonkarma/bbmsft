#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit

/// BMSwift - Components
/// Custom text field with consistent styling and behavior
///
/// Dependencies:
/// - SwiftUI: Primary UI framework
/// - UIKit: Native text field implementation
public struct CustomTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType
    private let autocapitalizationType: UITextAutocapitalizationType
    
    public init(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .sentences
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalizationType
    }
    
    public var body: some View {
        CustomTextFieldRepresentable(
            text: $text,
            placeholder: placeholder,
            isSecure: isSecure,
            keyboardType: keyboardType,
            autocapitalizationType: autocapitalizationType
        )
        .frame(height: 44)
        .padding(.horizontal)
    }
}

private struct CustomTextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    let autocapitalizationType: UITextAutocapitalizationType
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecure
        textField.returnKeyType = isSecure ? .done : .next
        textField.backgroundColor = .systemBackground
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextFieldRepresentable
        
        init(_ parent: CustomTextFieldRepresentable) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                parent.text = updatedText
            }
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

#if DEBUG
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomTextField(
                text: .constant(""),
                placeholder: "Email",
                keyboardType: .emailAddress,
                autocapitalizationType: .none
            )
            CustomTextField(
                text: .constant(""),
                placeholder: "Password",
                isSecure: true
            )
        }
        .padding()
    }
}
#endif
#endif
