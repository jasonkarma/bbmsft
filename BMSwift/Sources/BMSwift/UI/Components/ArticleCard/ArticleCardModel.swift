import Foundation

@available(iOS 13.0, *)
public protocol ArticleCardModel: Identifiable, Hashable {
    var id: Int { get }
    var title: String { get }
    var intro: String { get }
    var mediaName: String { get }
    var visitCount: Int { get }
    var likeCount: Int { get }
    var platform: Int { get }
    var clientLike: Bool { get }
    var clientVisit: Bool { get }
    var clientKeep: Bool { get }
}
