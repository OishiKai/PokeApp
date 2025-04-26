import SwiftUI

struct MainTabView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    MainTabView()
} 