import Foundation

public enum ViewState {
    case idle
    case loading
    case success(Any)
    case error(Error)
}
