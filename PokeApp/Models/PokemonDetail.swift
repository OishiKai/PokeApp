import Foundation

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let baseHappiness: Int
    let captureRate: Int
    let growthRate: GrowthRate
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [Genera]
    let habitat: Habitat?
    let isLegendary: Bool
    let isMythical: Bool
    let shape: Shape
    let varieties: [Variety]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case baseHappiness = "base_happiness"
        case captureRate = "capture_rate"
        case growthRate = "growth_rate"
        case flavorTextEntries = "flavor_text_entries"
        case genera
        case habitat
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
        case shape
        case varieties
    }
    
    struct GrowthRate: Codable {
        let name: String
        let url: String
    }
    
    struct FlavorTextEntry: Codable {
        let flavorText: String
        let language: Language
        let version: Version
        
        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language
            case version
        }
    }
    
    struct Language: Codable {
        let name: String
        let url: String
    }
    
    struct Version: Codable {
        let name: String
        let url: String
    }
    
    struct Genera: Codable {
        let genus: String
        let language: Language
    }
    
    struct Habitat: Codable {
        let name: String
        let url: String
    }
    
    struct Shape: Codable {
        let name: String
        let url: String
    }
    
    struct Variety: Codable {
        let isDefault: Bool
        let pokemon: PokemonReference
        
        enum CodingKeys: String, CodingKey {
            case isDefault = "is_default"
            case pokemon
        }
    }
    
    struct PokemonReference: Codable {
        let name: String
        let url: String
    }
} 