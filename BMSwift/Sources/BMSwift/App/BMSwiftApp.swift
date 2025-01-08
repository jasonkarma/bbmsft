#if canImport(SwiftUI) && os(iOS)
import SwiftUI

// Removed @main as this is a library
struct BMSwiftMainView: View {
    var body: some View {
        LoginView()
    }
}

struct BMSwiftMainView_Previews: PreviewProvider {
    static var previews: some View {
        BMSwiftMainView()
    }
}
#endif
