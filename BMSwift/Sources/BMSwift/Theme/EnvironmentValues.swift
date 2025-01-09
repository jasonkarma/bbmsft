#if canImport(SwiftUI) && os(iOS)
import SwiftUI

@available(iOS 13.0, *)
struct DismissAction {
    let action: () -> Void
    
    func callAsFunction() {
        action()
    }
}

@available(iOS 13.0, *)
private struct DismissActionKey: EnvironmentKey {
    static let defaultValue: DismissAction = DismissAction(action: {})
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var dismissAction: DismissAction {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
}

@available(iOS 13.0, *)
extension View {
    func provideDismissAction(_ action: @escaping () -> Void) -> some View {
        environment(\.dismissAction, DismissAction(action: action))
    }
}
#endif
