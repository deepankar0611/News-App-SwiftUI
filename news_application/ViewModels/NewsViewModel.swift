import SwiftUI
import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var errorMessage: String? // Must be String?
    @Published var isLoading: Bool = false
    private let newsService = NewsService()

    func loadNews(category: String? = nil) async {
        isLoading = true
        errorMessage = nil // String?
        
        do {
            articles = try await newsService.fetchNews(category: category)
            errorMessage = nil // String?
        } catch {
            errorMessage = "Failed to load news: \(error.localizedDescription)" // String to String?
            articles = []
        }
        
        isLoading = false
    }
}
