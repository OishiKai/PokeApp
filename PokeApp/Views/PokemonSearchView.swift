import SwiftUI

struct PokemonSearchView: View {
    @State private var searchText = ""
    @State private var pokemon: Pokemon?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSubmit: searchPokemon)
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if let pokemon = pokemon {
                    PokemonDetailView(pokemon: pokemon)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Search Pokemon")
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
                errorMessage = "ポケモンが見つかりませんでした"
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

