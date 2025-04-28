import Foundation

// URLSessionProtocolの定義
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

class PokemonAPI {
    static let shared = PokemonAPI()
    private let baseURL = "https://pokeapi.co/api/v2"
    private var cache: [String: Pokemon] = [:]
    private var detailCache: [String: PokemonDetail] = [:]
    
    // テスト用にURLSessionを注入できるようにする
    var session: URLSessionProtocol = URLSession.shared
    
    func searchPokemon(id: String) async throws -> Pokemon {
        // キャッシュに存在する場合はキャッシュから返す
        if let cachedPokemon = cache[id.lowercased()] {
            return cachedPokemon
        }
        
        // キャッシュにない場合はAPIから取得
        let url = URL(string: "\(baseURL)/pokemon/\(id.lowercased())")!
        let (data, response) = try await session.data(from: url)
        
        // HTTPレスポンスのステータスコードをチェック
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
            // 取得したデータをキャッシュに保存
            cache[id.lowercased()] = pokemon
            return pokemon
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getPokemonDetail(id: String) async throws -> PokemonDetail {
        // キャッシュに存在する場合はキャッシュから返す
        if let cachedDetail = detailCache[id.lowercased()] {
            return cachedDetail
        }
        
        // キャッシュにない場合はAPIから取得
        let url = URL(string: "\(baseURL)/pokemon/\(id.lowercased())")!
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let detail = try JSONDecoder().decode(PokemonDetail.self, from: data)
            
            // 取得したデータをキャッシュに保存
            detailCache[id.lowercased()] = detail
            return detail
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    // キャッシュをクリアするメソッド
    func clearCache() {
        cache.removeAll()
        detailCache.removeAll()
    }
}

enum APIError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(DecodingError)
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 
