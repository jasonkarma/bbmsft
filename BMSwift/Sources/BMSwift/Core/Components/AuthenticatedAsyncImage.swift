#if canImport(UIKit) && os(iOS)
import SwiftUI
import UIKit

public struct AuthenticatedAsyncImage<Content: View>: View {
    let url: URL
    let token: String
    let content: (AsyncImagePhase) -> Content
    @State private var imagePhase: AsyncImagePhase = .empty
    
    public init(
        url: URL,
        token: String,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.token = token
        self.content = content
    }
    
    private func logRequest(_ request: URLRequest) {
        print("🌐 Network Request:")
        print("  URL: \(request.url?.absoluteString ?? "nil")")
        print("  Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("    \(key): \(value)")
        }
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        print("📥 Response:")
        print("  Status: \(response.statusCode)")
        print("  Headers:")
        response.allHeaderFields.forEach { key, value in
            print("    \(key): \(value)")
        }
        
        if !(200...299).contains(response.statusCode),
           let responseStr = String(data: data ?? Data(), encoding: .utf8) {
            print("  Body: \(responseStr)")
        }
    }
    
    private func logImageCreation(_ image: UIImage) {
        print("✅ Image created:")
        print("  Size: \(image.size.width)x\(image.size.height)")
        print("  Scale: \(image.scale)")
        print("  Orientation: \(image.imageOrientation.rawValue)")
    }
    
    private func logImageError(_ data: Data) {
        print("❌ Image creation failed:")
        print("  Data size: \(data.count) bytes")
        let previewData = data.prefix(100)
        print("  Preview: \(previewData.map { String(format: "%02x", $0) }.joined())")
    }
    
    public var body: some View {
        content(imagePhase)
            .task {
                print("🌐 Making request to URL: \(url.absoluteString)")
                print("🔑 Using token prefix: \(String(token.prefix(10)))...")
                
                var request = URLRequest(url: url)
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.cachePolicy = .returnCacheDataElseLoad
                
                logRequest(request)
                
                do {
                    let (responseData, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Invalid response type: \(type(of: response))")
                        imagePhase = .failure(ImageError.invalidResponse(statusCode: 0))
                        return
                    }
                    
                    print("📡 Response status code: \(httpResponse.statusCode)")
                    print("📋 Response headers: \(httpResponse.allHeaderFields)")
                    
                    print("📦 Received data size: \(responseData.count) bytes")
                    if responseData.count < 1000 {
                        if let text = String(data: responseData, encoding: .utf8) {
                            print("📄 Response content: \(text)")
                        }
                    }
                    
                    logResponse(httpResponse, data: responseData)
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        imagePhase = .failure(ImageError.invalidResponse(statusCode: httpResponse.statusCode))
                        return
                    }
                    
                    if let image = UIImage(data: responseData) {
                        logImageCreation(image)
                        imagePhase = .success(Image(uiImage: image))
                    } else {
                        logImageError(responseData)
                        imagePhase = .failure(ImageError.invalidData)
                    }
                } catch {
                    print("❌ Network error: \(error.localizedDescription)")
                    imagePhase = .failure(ImageError.networkError(error))
                }
            }
    }
}

private enum ImageError: Error, LocalizedError {
    case invalidData
    case invalidResponse(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Failed to create image from data"
        case .invalidResponse(let statusCode):
            return "Server returned status code: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

#if DEBUG
struct AuthenticatedAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        if let url = URL(string: "https://example.com/image.jpg") {
            AuthenticatedAsyncImage(url: url, token: "test-token") { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(let error):
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .font(.caption)
                    }
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}
#endif
#endif
