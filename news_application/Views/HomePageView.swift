import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = NewsViewModel()
    @EnvironmentObject private var favoritesManager: FavoritesManager // 🔥 Change from @StateObject to @EnvironmentObject
    @State private var showError = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.articles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            NewsCard(
                                article: article,
                                isFavorite: favoritesManager.isFavorite(article),
                                toggleFavorite: { favoritesManager.toggleFavorite(article) }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Top U.S. Headlines")
            .task {
                await viewModel.loadNews()
            }
            .overlay {
                if viewModel.articles.isEmpty && viewModel.errorMessage == nil {
                    ProgressView("Loading news...")
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("Retry")) {
                        Task { await viewModel.loadNews() }
                    }
                )
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                showError = newValue != nil
            }
        }
    }
}




struct NewsCard: View {
    let article: Article
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            
            // Favorite Icon
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray) // 🔥 This will now stay red when favorited
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle()) // Avoids link styling interference
        }
        .padding()
        .background(.background)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
