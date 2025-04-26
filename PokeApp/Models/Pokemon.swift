import Foundation

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [PokemonType]
    
    struct Sprites: Codable {
        let frontDefault: String
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
    
    struct PokemonType: Codable {
        let typeInfo: TypeInfo
        
        struct TypeInfo: Codable {
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case typeInfo = "type"
        }
    }
}
