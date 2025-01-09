#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public extension View {
    func navigate<Destination: View>(
        to destination: Destination,
        when binding: Binding<Bool>,
        navigationStyle: NavigationStyle = .push
    ) -> some View {
        Group {
            if navigationStyle == .push {
                NavigationLink(
                    destination: destination,
                    isActive: binding,
                    label: { self }
                )
            } else {
                self.sheet(isPresented: binding) {
                    destination
                }
            }
        }
    }
}

public enum NavigationStyle {
    case push
    case modal
}
#endif
