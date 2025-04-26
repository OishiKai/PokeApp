import SwiftUI

struct PokemonListView: View {
    @State private var pokemons: [Pokemon] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(pokemons) { pokemon in
                                PokemonGridItem(pokemon: pokemon)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Pokedex")
            .task {
                await loadPokemons()
            }
        }
    }
    
    private func loadPokemons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 最初の15件のポケモンを取得
            var loadedPokemons: [Pokemon] = []
            for id in 1...15 {
                let pokemon = try await PokemonAPI.shared.searchPokemon(name: String(id))
                loadedPokemons.append(pokemon)
            }
            pokemons = loadedPokemons
        } catch {
            errorMessage = "Failed to load Pokemon"
        }
        
        isLoading = false
    }
}

struct PokemonGridItem: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            Text("#\(pokemon.id)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(pokemon.name.capitalized)
                .font(.headline)
            
            HStack {
                ForEach(pokemon.types, id: \.typeInfo.name) { type in
                    Text(type.typeInfo.name.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(PokemonTypeColor.color(for: type.typeInfo.name))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 150, height: 150)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 