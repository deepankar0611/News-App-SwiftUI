import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCategory: String? = nil
    @State private var favorites: Set<UUID> = []
    
    private let categories = [
        "All": nil,
        "Business": "business",
        "Entertainment": "entertainment",
        "Health": "health",
        "Science": "science",
        "Sports": "sports",
        "Technology": "technology"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                categoryPicker
                contentView
            }
            .navigationTitle("Top Headlines")
            .task {
                await viewModel.loadNews(category: selectedCategory)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories.keys.sorted(), id: \.self) { category in
                    Button(action: {
                        // Fix: Use flatMap to handle the double optional
                        selectedCategory = categories[category].flatMap { $0 }
                        Task {
                            await viewModel.loadNews(category: selectedCategory)
                        }
                    }) {
                        Text(category)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == categories[category].flatMap { $0 } ?
                                      Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == categories[category].flatMap { $0 } ?
                                           .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else {
                // Explicitly handle errorMessage as String? without unwrapping
                switch viewModel.errorMessage {
                case .some(let error): // error is String
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                case .none:
                    articlesList
                }
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView("Loading news...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var articlesList: some View {
        List(viewModel.articles) { article in
            NavigationLink(destination: ArticleDetailView(article: article)) {
                NewsCard(
                    article: article,
                    isFavorite: favorites.contains(article.id),
                    toggleFavorite: {
                        if favorites.contains(article.id) {
                            favorites.remove(article.id)
                        } else {
                            favorites.insert(article.id)
                        }
                    }
                )
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - News Card

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
            
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - Article Row (Kept for reference)

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            if let description = article.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    HomePageView()
}
