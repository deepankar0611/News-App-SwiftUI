import SwiftUI

@main
struct NewsAppApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomePageView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart")
                    }
            }
            .environmentObject(favoritesManager)  // Share across tabs
        }
    }
}
