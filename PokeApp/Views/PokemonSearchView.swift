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
                pokemon = try await PokemonAPI.shared.searchPokemon(name: searchText)
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

struct PokemonDetailView: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200, height: 200)
            
            Text(pokemon.name.capitalized)
                .font(.title)
            
            HStack {
                ForEach(pokemon.types, id: \.typeInfo.name) { type in
                    Text(type.typeInfo.name.capitalized)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
} 
