import SwiftUI

/// 画像キャッシュを管理するシングルトンクラス
/// メモリ内に画像をキャッシュし、重複したネットワークリクエストを防ぎます
class ImageCache {
    /// シングルトンインスタンス
    static let shared = ImageCache()
    
    /// NSCacheを使用して画像をキャッシュ
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // キャッシュする画像の最大数を制限（メモリ使用量の制御）
        cache.countLimit = 100
    }
    
    /// キャッシュから画像を取得
    /// - Parameter key: 画像のURL文字列
    /// - Returns: キャッシュされた画像。存在しない場合はnil
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// 画像をキャッシュに保存
    /// - Parameters:
    ///   - image: キャッシュする画像
    ///   - key: 画像のURL文字列
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

/// キャッシュ機能付きのAsyncImage
/// 通常のAsyncImageを拡張し、画像のキャッシュ機能を提供します
/// - Content: 画像を表示するためのカスタムビュー
/// - Placeholder: ローディング中に表示するビュー
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    // MARK: - Properties
    
    /// 画像のURL
    private let url: URL
    
    /// 画像のスケール（デフォルト: 1.0）
    private let scale: CGFloat
    
    /// 画像を表示するためのカスタムビュー
    private let content: (Image) -> Content
    
    /// ローディング中に表示するビュー
    private let placeholder: () -> Placeholder
    
    // MARK: - Initialization
    
    /// イニシャライザ
    /// - Parameters:
    ///   - url: 画像のURL
    ///   - scale: 画像のスケール（デフォルト: 1.0）
    ///   - content: 画像を表示するためのカスタムビュー
    ///   - placeholder: ローディング中に表示するビュー
    init(
        url: URL,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = placeholder
    }
    
    // MARK: - Body

    var body: some View {
        // キャッシュに画像が存在する場合は、キャッシュから表示
        if let cached = ImageCache.shared.get(forKey: url.absoluteString) {
            content(Image(uiImage: cached))
        } else {
            // キャッシュにない場合は、AsyncImageでダウンロード
            AsyncImage(
                url: url,
                scale: scale,
                content: { image in
                    content(image)
                        .onAppear {
                            // 画像が表示されたら、キャッシュに保存
                            Task {
                                if let uiImage = await loadUIImage(from: url) {
                                    ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                                }
                            }
                        }
                },
                placeholder: placeholder
            )
        }
    }
    
    /// URLからUIImageを直接読み込む
    private func loadUIImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
}

// MARK: - Image Extension

extension Image {
    /// SwiftUIのImageをUIImageに変換
    /// - Returns: 変換されたUIImage。変換に失敗した場合はnil
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        // ビューのサイズを設定（一時的に大きめのサイズを設定）
        let tempSize = CGSize(width: 1000, height: 1000)
        view?.bounds = CGRect(origin: .zero, size: tempSize)
        view?.backgroundColor = .clear
        
        // ビューをレイアウト
        view?.layoutIfNeeded()
        
        // 実際のサイズを取得
        let actualSize = view?.systemLayoutSizeFitting(
            CGSize(width: tempSize.width, height: tempSize.height),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        ) ?? tempSize
        
        // ビューのサイズを実際のサイズに設定
        view?.bounds = CGRect(origin: .zero, size: actualSize)
        
        // ビューをUIImageにレンダリング
        let renderer = UIGraphicsImageRenderer(size: actualSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
} 