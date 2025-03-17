//
//  NewsViewModel.swift
//  news_application
//
//  Created by Deepankar Singh on 17/03/25.
//

import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var errorMessage: String?
    private let newsService = NewsService()

    func loadNews() async {
        do {
            articles = try await newsService.fetchNews()
        } catch {
            errorMessage = "Failed to load news: \(error.localizedDescription)"
        }
    }
}
