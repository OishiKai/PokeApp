import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var detail: PokemonDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ポケモンの画像
                AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                
                // ポケモンの名前
                Text(pokemon.name.capitalized)
                    .font(.title)
                
                // タイプ
                HStack {
                    ForEach(pokemon.types, id: \.typeInfo.name) { type in
                        Text(type.typeInfo.name.capitalized)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(PokemonTypeColor.color(for: type.typeInfo.name))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(Color(uiColor: .systemRed))
                } else if let detail = detail {
                    // 詳細情報
                    VStack(alignment: .leading, spacing: 15) {
                        // 説明文
                        if let description = detail.flavorTextEntries.first(where: { $0.language.name == "en" })?.flavorText {
                            Text(description.replacingOccurrences(of: "\n", with: " "))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(Color(uiColor: .systemGroupedBackground))
                                .cornerRadius(10)
                        }
                        
                        // 分類
                        if let genus = detail.genera.first(where: { $0.language.name == "en" })?.genus {
                            DetailRow(title: "Category", value: genus)
                        }
                        
                        // 生息地
                        DetailRow(title: "Habitat", value: detail.habitat.name)
                        
                        // 捕獲率
                        DetailRow(title: "Capture Rate", value: "\(detail.captureRate)%")
                        
                        // 成長速度
                        DetailRow(title: "Growth Rate", value: detail.growthRate.name)
                        
                        // 伝説/幻のポケモン
                        if detail.isLegendary {
                            Text("Legendary Pokemon")
                                .foregroundColor(Color(uiColor: .systemOrange))
                                .padding(.top)
                        }
                        if detail.isMythical {
                            Text("Mythical Pokemon")
                                .foregroundColor(Color(uiColor: .systemPurple))
                                .padding(.top)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle(pokemon.name.capitalized)
        .task {
            await loadDetail()
        }
    }
    
    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            detail = try await PokemonAPI.shared.getPokemonDetail(id: String(pokemon.id))
        } catch let apiError as APIError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = "Failed to load Pokemon details: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
