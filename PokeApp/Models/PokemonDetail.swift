import Foundation

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [PokemonType]
    let cries: Cries
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case baseExperience = "base_experience"
        case height
        case weight
        case sprites
        case types
        case cries
    }
    
    struct Sprites: Codable {
        let frontDefault: String
        let backDefault: String?
        let frontShiny: String?
        let backShiny: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
            case backDefault = "back_default"
            case frontShiny = "front_shiny"
            case backShiny = "back_shiny"
        }
    }
    
    struct PokemonType: Codable {
        let slot: Int
        let type: TypeInfo
        
        struct TypeInfo: Codable {
            let name: String
            let url: String
        }
    }
    
    struct Cries: Codable {
        let latest: String
        let legacy: String?
    }
} 