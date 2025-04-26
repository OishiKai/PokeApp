import SwiftUI

struct PokemonSearchView: View {
    @State private var searchText = ""
    @State private var pokemon: Pokemon?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(Color(uiColor: .systemRed))
                } else if let pokemon = pokemon {
                    PokemonDetailView(pokemon: pokemon)
                } else {
                    ContentUnavailableView(
                        "Search Pokemon",
                        systemImage: "magnifyingglass",
                        description: Text("Enter Pokemon name or number")
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Search Pokemon")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer,
                prompt: "Search Pokemon"
            )
            .onSubmit(of: .search) {
                searchPokemon()
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func searchPokemon() {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                pokemon = try await PokemonAPI.shared.searchPokemon(id: searchText)
            } catch {
                errorMessage = "Pokemon not found"
            }
            isLoading = false
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search Pokemon", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSubmit)
            
            Button(action: onSubmit) {
                Image(systemName: "magnifyingglass")
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

