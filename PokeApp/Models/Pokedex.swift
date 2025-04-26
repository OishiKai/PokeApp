import Foundation

struct Pokedex: Identifiable {
    let id: Int
    let name: String
    let startId: Int
    let endId: Int
}

extension Pokedex {
    static let all: [Pokedex] = [
        Pokedex(id: 0, name: "National", startId: 1, endId: 1025),
        Pokedex(id: 1, name: "Kanto", startId: 1, endId: 151),
        Pokedex(id: 2, name: "Johto", startId: 152, endId: 251),
        Pokedex(id: 3, name: "Hoenn", startId: 252, endId: 386),
        Pokedex(id: 4, name: "Sinnoh", startId: 387, endId: 493),
        Pokedex(id: 5, name: "Unova", startId: 494, endId: 649),
        Pokedex(id: 6, name: "Kalos", startId: 650, endId: 721),
        Pokedex(id: 7, name: "Alola", startId: 722, endId: 809),
        Pokedex(id: 8, name: "Galar", startId: 810, endId: 905),
        Pokedex(id: 9, name: "Paldea", startId: 906, endId: 1025)
    ]
    
    static func find(by id: Int) -> Pokedex {
        all.first { $0.id == id } ?? all[0]
    }
} 