import Foundation

class NewsService {
    private enum Constants {
        static let apiKey = "c4e86d1628904a1f852685c2f1a692ff"
        static let baseURL = "https://newsapi.org/v2/top-headlines"
        static let country = "us"
    }
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    enum NewsError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case invalidResponse
    }
    
    func fetchNews(category: String? = nil) async throws -> [Article] {
        guard var urlComponents = URLComponents(string: Constants.baseURL) else {
            throw NewsError.invalidURL
        }
        
        var queryItems = [
            URLQueryItem(name: "country", value: Constants.country),
            URLQueryItem(name: "apiKey", value: Constants.apiKey)
        ]
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NewsError.invalidURL
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NewsError.invalidResponse
            }
            let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            return newsResponse.articles
        } catch {
            throw NewsError.networkError(error)
        }
    }
}
