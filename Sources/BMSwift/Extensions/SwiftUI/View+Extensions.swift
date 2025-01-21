#if canImport(SwiftUI) && os(iOS)
import SwiftUI

public extension View {
    func navigate<Destination: View>(
        to destination: Destination,
        when binding: Binding<Bool>
    ) -> some View {
        NavigationStack {
            self.navigationDestination(isPresented: binding) {
                destination
            }
        }
    }
}
#endif
