import Foundation

class PokemonAPI {
    static let shared = PokemonAPI()
    private let baseURL = "https://pokeapi.co/api/v2"
    private var cache: [String: Pokemon] = [:]
    
    func searchPokemon(name: String) async throws -> Pokemon {
        // キャッシュに存在する場合はキャッシュから返す
        if let cachedPokemon = cache[name.lowercased()] {
            print("キャッシュから取得: \(name)")
            return cachedPokemon
        }
        
        // キャッシュにない場合はAPIから取得
        print("APIリクエスト: \(name)")
        let url = URL(string: "\(baseURL)/pokemon/\(name.lowercased())")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
        
        // 取得したデータをキャッシュに保存
        cache[name.lowercased()] = pokemon
        return pokemon
    }
    
    // キャッシュをクリアするメソッド
    func clearCache() {
        cache.removeAll()
    }
} 