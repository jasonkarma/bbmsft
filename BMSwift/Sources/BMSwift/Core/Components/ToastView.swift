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
        GeometryReader { geometry in
            VStack {
                if isPresented {
                    HStack {
                        Spacer()
                        Text(message)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                            )
                            .shadow(radius: 4)
                        Spacer()
                    }
                    .padding(.top, geometry.safeAreaInsets.top - 100) // Position it higher
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        // Cancel any existing timer and create a new one
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [isPresented] in
                            // Only dismiss if this is still the same presentation
                            if isPresented {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.isPresented = false
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
    }
}

@available(iOS 13.0, *)
struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isPresented {
                ToastView(message: message, isPresented: $isPresented)
            }
        }
    }
}

@available(iOS 13.0, *)
public extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}
