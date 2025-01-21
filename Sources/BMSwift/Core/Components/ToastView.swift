#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool
    
    public init(message: String, isPresented: Binding<Bool>) {
        self.message = message
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack {
            if isPresented {
                Text(message)
                    .font(.subheadline)
                    .bmForegroundColor(AppColors.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .bmBackground(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

@available(iOS 13.0, *)
public extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        overlay(
            ToastView(message: message, isPresented: isPresented)
                .padding(.top, 60),
            alignment: .top
        )
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Background Content")
        }
        .toast(message: "This is a toast message", isPresented: .constant(true))
    }
}
#endif
#endif
