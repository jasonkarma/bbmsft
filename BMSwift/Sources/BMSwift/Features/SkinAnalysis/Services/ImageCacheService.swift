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
        let imageData = image.jpegData(compressionQuality: 0.8)
        let filePath = cacheDirectory.appendingPathComponent(identifier)
        try imageData?.write(to: filePath)
    }
    
    public func getCachedImage(withIdentifier identifier: String) -> UIImage? {
        let filePath = cacheDirectory.appendingPathComponent(identifier)
        guard let imageData = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: imageData)
    }
    
    public func cacheImageURL(_ url: String, withIdentifier identifier: String) {
        urlCache[identifier] = url
    }
    
    public func getCachedImageURL(withIdentifier identifier: String) -> String? {
        urlCache[identifier]
    }
}

#endif
