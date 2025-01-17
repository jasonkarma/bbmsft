#if canImport(SwiftUI) && os(iOS)
import SwiftUI
import WebKit

struct HTMLTextView: View {
    let htmlContent: String
    @State private var dynamicHeight: CGFloat = .zero
    
    var body: some View {
        WebView(htmlContent: htmlContent, dynamicHeight: $dynamicHeight)
            .frame(height: dynamicHeight)
    }
}

private struct WebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var dynamicHeight: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.configuration.defaultWebpagePreferences = preferences
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        
        // Add script message handler
        let userController = WKUserContentController()
        userController.add(context.coordinator, name: "heightChanged")
        configuration.userContentController = userController
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Replace local development URLs with production URLs
        let processedContent = htmlContent
            .replacingOccurrences(of: "http://127.0.0.1/media/", with: "https://wiki.kinglyrobot.com/media/")
        
        // Wrap content in proper HTML with styling
        let htmlWithBase = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        :root {
            color-scheme: light dark;
        }
        body {
            font-family: -apple-system, system-ui;
            line-height: 1.5;
            font-size: 16px;
            margin: 0;
            padding: 0;
            background-color: transparent;
        }
        .content-wrapper {
            padding: 0;
            margin: 0;
            width: 100%;
        }
        img {
            width: 100%;
            height: auto;
            display: block;
            margin: 12px 0;
            border-radius: 6px;
        }
        h4 {
            font-size: 18px;
            font-weight: 600;
            margin: 16px 0 8px 0;
        }
        p {
            margin: 8px 0;
            line-height: 1.6;
        }
        ol, ul {
            padding-left: 20px;
            margin: 8px 0;
        }
        li {
            margin: 6px 0;
        }
        figure {
            margin: 16px 0;
            padding: 0;
            width: 100%;
        }
        figure img {
            width: 100%;
            margin: 0;
        }
        </style>
        </head>
        <body>
        <div class="content-wrapper">
            \(processedContent)
        </div>
        <script>
        function updateHeight() {
            const height = document.documentElement.scrollHeight;
            window.webkit.messageHandlers.heightChanged.postMessage(height);
        }
        window.addEventListener('load', updateHeight);
        window.addEventListener('resize', updateHeight);
        </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlWithBase, baseURL: URL(string: "https://wiki.kinglyrobot.com"))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            updateHeight(webView)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightChanged",
               let height = message.body as? CGFloat {
                DispatchQueue.main.async {
                    self.parent.dynamicHeight = height
                }
            }
        }
        
        private func updateHeight(_ webView: WKWebView) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { height, _ in
                if let height = height as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.dynamicHeight = height
                    }
                }
            }
        }
    }
}

#if DEBUG
struct HTMLTextView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLTextView(htmlContent: """
            <p>This is a test paragraph with an image:</p>
            <figure>
                <img src="http://127.0.0.1/media/test.jpg" alt="Test Image"/>
            </figure>
            <p>Another paragraph after the image.</p>
            """)
    }
}
#endif

#endif
