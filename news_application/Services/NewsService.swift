//
//  NewsService.swift
//  news_application
//
//  Created by Deepankar Singh on 17/03/25.
//

import Foundation

class NewsService {
    private let apiKey = "c4e86d1628904a1f852685c2f1a692ff"
    private let baseURL = "https://newsapi.org/v2/top-headlines?country=us"

    func fetchNews() async throws -> [Article] {
        let urlString = "\(baseURL)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(NewsResponse.self, from: data)
        return response.articles
    }
}
