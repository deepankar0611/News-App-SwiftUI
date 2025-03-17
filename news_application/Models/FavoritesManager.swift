import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteArticles: [Article] = [] // 🔥 No need for `private(set)`, let SwiftUI observe it

    init() {
        loadFavorites()
    }

    func isFavorite(_ article: Article) -> Bool {
        favoriteArticles.contains { $0.id == article.id }
    }

    func toggleFavorite(_ article: Article) {
        if isFavorite(article) {
            favoriteArticles.removeAll { $0.id == article.id }
        } else {
            favoriteArticles.append(article)
        }
        saveFavorites()
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteArticles) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteArticles")
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "FavoriteArticles"),
           let decoded = try? JSONDecoder().decode([Article].self, from: data) {
            favoriteArticles = decoded
        }
    }
}
