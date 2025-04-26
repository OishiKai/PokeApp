//
//  PokeAppUITests.swift
//  PokeAppUITests
//
//  Created by Kai Oishi on 2025/04/26.
//

import XCTest

final class PokeAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - メインタブビュー関連のテスト
    
    @MainActor
    func testTabNavigation() throws {
        // アプリを起動
        let app = XCUIApplication()
        app.launch()
        
        // デフォルトでNationalタブが表示されていることを確認
        XCTAssertTrue(app.navigationBars["National"].exists)
        
        // Searchタブに切り替え
        app.tabBars.buttons["Search"].tap()
        
        // Searchタブが表示されていることを確認
        XCTAssertTrue(app.navigationBars["Search Pokemon"].exists)
        
        // Settingsタブに切り替え
        app.tabBars.buttons["Settings"].tap()
        
        // Settingsタブが表示されていることを確認
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        // 再度Pokedexタブに戻る
        app.tabBars.buttons["Pokedex"].tap()
        
        // Pokedexタブが表示されていることを確認
        XCTAssertTrue(app.navigationBars["National"].exists)
    }
    
    @MainActor
    func testTabBarItems() throws {
        // アプリを起動
        let app = XCUIApplication()
        app.launch()
        
        // タブバーに3つのタブが存在することを確認
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        
        // 各タブのラベルとアイコンが存在することを確認
        XCTAssertTrue(app.tabBars.buttons["Pokedex"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }
    
    // MARK: - ポケモンリストビュー関連のテスト
    
    @MainActor
    func testPokemonListView() throws {
        // アプリを起動
        let app = XCUIApplication()
        app.launch()
        
        // ポケモンリストが表示されるまで待機
        let pokemonGrid = app.scrollViews.firstMatch
        XCTAssertTrue(pokemonGrid.waitForExistence(timeout: 5))
        
        // ポケモンアイテムが表示されていることを確認
        let pokemonItems = app.scrollViews.firstMatch.otherElements
        XCTAssertGreaterThan(pokemonItems.count, 0)
    }
    
    @MainActor
    func testPokemonListScrolling() throws {
        // アプリを起動
        let app = XCUIApplication()
        app.launch()
        
        // ポケモンリストが表示されるまで待機
        let pokemonGrid = app.scrollViews.firstMatch
        XCTAssertTrue(pokemonGrid.waitForExistence(timeout: 5))
        
        // スクロール可能なことを確認
        XCTAssertTrue(pokemonGrid.isEnabled, "Scroll view is not enabled")
        XCTAssertTrue(pokemonGrid.isHittable, "Scroll view is not hittable")
        
        // スクロールを実行
        pokemonGrid.swipeUp(velocity: .fast)
        
        // スクロール操作が成功したことを確認
        // スクロールビューが操作可能な状態を維持していることを確認
        XCTAssertTrue(pokemonGrid.isEnabled, "Scroll view is not enabled after scrolling")
        XCTAssertTrue(pokemonGrid.isHittable, "Scroll view is not hittable after scrolling")
    }
}
