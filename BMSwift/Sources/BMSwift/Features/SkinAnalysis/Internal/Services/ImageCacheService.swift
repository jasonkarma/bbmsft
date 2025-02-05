#if canImport(UIKit) && os(iOS)
import Foundation
import UIKit

public protocol ImageCacheService {
    func cacheImage(_ image: UIImage, withIdentifier identifier: String) throws
    func getCachedImage(withIdentifier identifier: String) -> UIImage?
    func cacheImageURL(_ url: String, withIdentifier identifier: String)
    func getCachedImageURL(withIdentifier identifier: String) -> String?
}

public final class ImageCacheServiceImpl: ImageCacheService {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private var urlCache: [String: String] = [:]
    
    public init() throws {
        self.fileManager = .default
        
        let cacheDir = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        self.cacheDirectory = cacheDir.appendingPathComponent("ImageCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    public func cacheImage(_ image: UIImage, withIdentifier identifier: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(identifier)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw ImageCacheError.compressionFailed
        }
        try data.write(to: fileURL)
    }
    
    public func getCachedImage(withIdentifier identifier: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(identifier)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    public func cacheImageURL(_ url: String, withIdentifier identifier: String) {
        urlCache[identifier] = url
    }
    
    public func getCachedImageURL(withIdentifier identifier: String) -> String? {
        return urlCache[identifier]
    }
}

public enum ImageCacheError: LocalizedError {
    case compressionFailed
    
    public var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image for caching"
        }
    }
}
#endif
