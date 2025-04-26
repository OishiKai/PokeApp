import Foundation

class PokemonAPI {
    static let shared = PokemonAPI()
    private let baseURL = "https://pokeapi.co/api/v2"
    private var cache: [String: Pokemon] = [:]
    
    func searchPokemon(id: String) async throws -> Pokemon {
        // キャッシュに存在する場合はキャッシュから返す
        if let cachedPokemon = cache[id.lowercased()] {
            return cachedPokemon
        }
        
        // キャッシュにない場合はAPIから取得
        let url = URL(string: "\(baseURL)/pokemon/\(id.lowercased())")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
        
        // 取得したデータをキャッシュに保存
        cache[id.lowercased()] = pokemon
        return pokemon
    }
    
    // キャッシュをクリアするメソッド
    func clearCache() {
        cache.removeAll()
    }
} 