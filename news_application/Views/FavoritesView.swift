import SwiftUI


struct FavoritesView: View {
    @EnvironmentObject private var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            if favoritesManager.favoriteArticles.isEmpty {
                VStack {
                    Text("No Favorites Yet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Tap the heart icon on articles to add them here.")
                        .foregroundColor(.gray)
                }
                .navigationTitle("Favorites")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(favoritesManager.favoriteArticles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                NewsCard(
                                    article: article,
                                    isFavorite: true,
                                    toggleFavorite: { favoritesManager.toggleFavorite(article) }
                                )
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Favorites")
            }
        }
    }
}
