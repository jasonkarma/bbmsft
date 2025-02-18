import Foundation

@available(iOS 13.0, *)
public protocol ArticleCardModel {
    var id: Int { get }
    var title: String { get }
    var intro: String { get }
    var mediaName: String { get }
}
