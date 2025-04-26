import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PokemonListView()
                .tabItem {
                    Label("Pokedex", systemImage: "list.bullet")
                }
                
            PokemonSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
} 