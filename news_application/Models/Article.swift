//
//  Article.swift
//  news_application
//
//  Created by Deepankar Singh on 17/03/25.
//

import Foundation

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?

    enum CodingKeys: String, CodingKey {
        case title, description, url, urlToImage, id
    }
}

struct NewsResponse: Codable {
    let articles: [Article]
}
