import Foundation

class PokemonAPI {
    static let shared = PokemonAPI()
    private let baseURL = "https://pokeapi.co/api/v2"
    
    func searchPokemon(name: String) async throws -> Pokemon {
        let url = URL(string: "\(baseURL)/pokemon/\(name.lowercased())")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Pokemon.self, from: data)
    }
} 