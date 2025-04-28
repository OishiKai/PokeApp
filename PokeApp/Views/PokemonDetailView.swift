import SwiftUI
import AVFoundation
import OggDecoder

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var detail: PokemonDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var isConverting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ポケモンの画像
                AsyncImage(url: URL(string: detail?.sprites.frontDefault ?? pokemon.sprites.frontDefault)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                
                // ポケモンの名前
                Text(pokemon.name.capitalized)
                    .font(.title)
                
                // タイプ
                HStack {
                    ForEach(detail?.types ?? [], id: \.type.name) { type in
                        Text(type.type.name.capitalized)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(PokemonTypeColor.color(for: type.type.name))
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
                        // 基本情報
                        DetailRow(title: "Height", value: "\(Double(detail.height) / 10.0)m")
                        DetailRow(title: "Weight", value: "\(Double(detail.weight) / 10.0)kg")
                        if let baseExp = detail.baseExperience {
                            DetailRow(title: "Base Experience", value: "\(baseExp)")
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle(pokemon.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isPlaying {
                        player?.pause()
                    } else if let cryUrl = detail?.cries.latest {
                        playCry(url: cryUrl)
                    }
                    isPlaying.toggle()
                }) {
                    if isConverting {
                        ProgressView()
                    } else {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundColor(isPlaying ? .red : .blue)
                    }
                }
                .disabled(isConverting)
            }
        }
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
    
    private func playCry(url: String) {
        // URLをそのまま使用
        guard let audioUrl = URL(string: url) else { return }
        
        isConverting = true
        
        // 一時ファイルのURLを作成
        let tempDir = FileManager.default.temporaryDirectory
        let oggUrl = tempDir.appendingPathComponent("\(pokemon.id)_cry.ogg")
        let wavUrl = tempDir.appendingPathComponent("\(pokemon.id)_cry.wav")
        
        // URLからデータをダウンロード
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: audioUrl)
                try data.write(to: oggUrl)
                
                // OggDecoderを使用して変換
                let decoder = OGGDecoder()
                
                await decoder.decode(oggUrl, into: wavUrl)
                player = AVPlayer(url: wavUrl)
                player?.play()
                
                // 再生が終了したら再生状態をリセット
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                    isPlaying = false
                }
                
                isConverting = false
            } catch {
                print("Failed to download ogg file: \(error)")
                isConverting = false
            }
        }
    }
}
