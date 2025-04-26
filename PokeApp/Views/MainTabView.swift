import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PokemonSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            PokemonListView()
                .tabItem {
                    Label("Pokedex", systemImage: "list.bullet")
                }
        }
    }
} 