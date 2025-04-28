import SwiftUI
import Foundation

/// ポケモン一覧画面の状態を管理するViewModel
@MainActor
class PokemonListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoadingMore = false
    @Published var currentPage = 1
    
    // MARK: - AppStorage Properties
    @AppStorage("itemsPerPage") private var itemsPerPage = 10
    @AppStorage("selectedPokedex") private var selectedPokedex = 0
    
    // MARK: - Computed Properties
    private var currentPokedex: Pokedex {
        Pokedex.find(by: selectedPokedex)
    }
    
    var currentPokedexName: String {
        currentPokedex.name
    }
    
    // MARK: - Public Methods
    /// ポケモンの一覧を読み込む
    func loadPokemons() async {
        isLoading = true
        currentPage = 1
        pokemons.removeAll()
        
        do {
            var loadedPokemons: [Pokemon] = []
            let startId = currentPokedex.startId
            let endId = min(startId + itemsPerPage - 1, currentPokedex.endId)
            
            for id in startId...endId {
                let pokemon = try await PokemonAPI.shared.searchPokemon(id: String(id))
                loadedPokemons.append(pokemon)
            }
            pokemons = loadedPokemons
        } catch {
            self.errorMessage = "Failed to load Pokemon"
        }
        
        isLoading = false
    }
    
    /// 追加のポケモンを読み込む
    func loadMorePokemons() async {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        do {
            let startId = currentPokedex.startId + (currentPage * itemsPerPage)
            let endId = min(startId + itemsPerPage - 1, currentPokedex.endId)
            
            guard startId <= currentPokedex.endId else {
                isLoadingMore = false
                return
            }
            
            for id in startId...endId {
                let pokemon = try await PokemonAPI.shared.searchPokemon(id: String(id))
                pokemons.append(pokemon)
            }
            currentPage += 1
        } catch {
            print("Failed to load more Pokemon: \(error)")
        }
        
        isLoadingMore = false
    }
}

/// ポケモン一覧のメインビュー
struct PokemonListView: View {
    // MARK: - Properties
    @EnvironmentObject private var viewModel: PokemonListViewModel
    @AppStorage("selectedPokedex") private var selectedPokedex = 0
    
    var body: some View {
        NavigationStack {
            PokemonListContent()
                .navigationTitle(viewModel.currentPokedexName)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Picker("図鑑", selection: $selectedPokedex) {
                                ForEach(Pokedex.all) { pokedex in
                                    Text(pokedex.name).tag(pokedex.id)
                                }
                            }
                        } label: {
                            Image(systemName: "book.fill")
                        }
                    }
                }
        }
        .onChange(of: selectedPokedex) { oldValue, newValue in
            Task {
                await viewModel.loadPokemons()
            }
        }
        .task {
            await viewModel.loadPokemons()
        }
    }
}

/// ポケモン一覧のコンテンツビュー
private struct PokemonListContent: View {
    // MARK: - Properties
    @EnvironmentObject private var viewModel: PokemonListViewModel
    @State private var scrollViewHeight: CGFloat = 0
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                // ローディング表示
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
            } else if let error = viewModel.errorMessage {
                // エラー表示
                Text(error)
                    .foregroundColor(Color(uiColor: .systemRed))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
            } else {
                // ポケモン一覧表示
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.pokemons) { pokemon in
                            NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                                PokemonGridItem(pokemon: pokemon)
                            }
                        }
                    }
                    .padding(16)
                    
                    // 追加ローディング表示
                    if viewModel.isLoadingMore {
                        VStack {
                            ProgressView()
                                .padding()
                            Text("Loading more Pokemons...")
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    
                    // スクロール位置の監視用GeometryReader
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                      value: geometry.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 20)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            scrollViewHeight = geometry.size.height
                        }
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    // スクロール位置に応じて追加読み込み
                    if offset * 0.8 < scrollViewHeight {
                        Task { @MainActor in
                            guard !viewModel.isLoadingMore else { return }
                            await viewModel.loadMorePokemons()
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

/// スクロール位置の監視用PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// ポケモンのグリッドアイテムビュー
struct PokemonGridItem: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack {
            // ポケモンの画像
            CachedAsyncImage(url: URL(string: pokemon.sprites.frontDefault)!) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            // ポケモンのID
            Text("#\(pokemon.id)")
                .font(.caption)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            
            // ポケモンの名前
            Text(pokemon.name.capitalized)
                .font(.headline)
                .foregroundColor(Color(uiColor: .label))
            
            // ポケモンのタイプ
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
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color(uiColor: .systemFill).opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 