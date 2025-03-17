import SwiftUI
import WebKit

struct ArticleDetailView: View {
    let article: Article
    @State private var isLoading = true
    @State private var loadError: String?
    
    var body: some View {
        VStack {
            if let url = URL(string: article.url) {
                ZStack {
                    WebView(url: url, isLoading: $isLoading, loadError: $loadError)
                    if isLoading {
                        ProgressView("Loading news...")
                    }
                }
            } else {
                Text("Invalid article URL: \(article.url)")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            if let error = loadError {
                Text("Error loading news: \(error)")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .navigationTitle("News")
        .onAppear {
            print("Loading article with URL: \(article.url)")
        }
    }
}

// WKWebView wrapper for SwiftUI
struct WebView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: String?
    
    func makeUIViewController(context: Context) -> WKWebViewController {
        let controller = WKWebViewController(url: url)
        controller.webView.navigationDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: WKWebViewController, context: Context) {
        if uiViewController.url != url {
            uiViewController.url = url
            uiViewController.loadURL()
            isLoading = true
            loadError = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = error.localizedDescription
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = error.localizedDescription
        }
    }
}

// Custom UIViewController for WKWebView
class WKWebViewController: UIViewController {
    private(set) var webView: WKWebView
    var url: URL?
    
    init(url: URL) {
        self.webView = WKWebView(frame: .zero)
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadURL()
    }
    
    private func setupWebView() {
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }
    
    func loadURL() {
        guard let url = url else {
            print("No URL to load")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        print("Loading URL in WebView: \(url)")
    }
}

#Preview {
    ArticleDetailView(article: Article(
        title: "Sample News Title",
        description: "This is a sample description for the news article to test the detail view.",
        url: "https://example.com",
        urlToImage: "https://via.placeholder.com/400x300"
    ))
}
