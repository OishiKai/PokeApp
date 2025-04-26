//
//  PokeAppTests.swift
//  PokeAppTests
//
//  Created by Kai Oishi on 2025/04/26.
//

import Testing
import Foundation
@testable import PokeApp

// MARK: - Test Errors
enum TestError: Error {
    case expectedErrorWasNotThrown
}

// MARK: - Mock URLSession
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockError: Error?
    var mockResponse: URLResponse?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw APIError.invalidResponse
        }
        
        return (data, response)
    }
}

// MARK: - PokemonAPI Tests
final class PokemonAPITests {
    private var api: PokemonAPI!
    private var mockSession: MockURLSession!
    
    private func setUp() {
        mockSession = MockURLSession()
        api = PokemonAPI()
        // URLSessionをモックに置き換える
        api.session = mockSession
    }
    
    @Test func testSuccessfulPokemonSearch() async throws {
        setUp()
        
        // テストデータの準備
        let mockPokemon = Pokemon(
            id: 25,
            name: "pikachu",
            sprites: Pokemon.Sprites(frontDefault: "https://example.com/pikachu.png"),
            types: [Pokemon.PokemonType(typeInfo: Pokemon.PokemonType.TypeInfo(name: "electric"))]
        )
        
        let jsonData = try JSONEncoder().encode(mockPokemon)
        mockSession.mockData = jsonData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/25")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // テスト実行
        let result = try await api.searchPokemon(id: "25")
        
        // 検証
        #expect(result.id == 25)
        #expect(result.name == "pikachu")
        #expect(result.sprites.frontDefault == "https://example.com/pikachu.png")
        #expect(result.types[0].typeInfo.name == "electric")
    }
    
    @Test func testPokemonNotFound() async throws {
        setUp()
        
        // 404エラーの設定
        mockSession.mockData = Data() // 空のデータを設定
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/99999")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        // テスト実行と検証
        do {
            _ = try await api.searchPokemon(id: "99999")
            throw TestError.expectedErrorWasNotThrown
        } catch APIError.httpError(let statusCode) {
            #expect(statusCode == 404)
        }
    }
    
    @Test func testInvalidResponse() async throws {
        setUp()
        
        // 不正なJSONデータの設定
        mockSession.mockData = "invalid json".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/25")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // テスト実行と検証
        do {
            _ = try await api.searchPokemon(id: "25")
            throw TestError.expectedErrorWasNotThrown
        } catch APIError.decodingError {
            // デコードエラーが正しく捕捉されたことを確認
        }
    }
    
    @Test func testCacheFunctionality() async throws {
        setUp()
        
        // テストデータの準備
        let mockPokemon = Pokemon(
            id: 25,
            name: "pikachu",
            sprites: Pokemon.Sprites(frontDefault: "https://example.com/pikachu.png"),
            types: [Pokemon.PokemonType(typeInfo: Pokemon.PokemonType.TypeInfo(name: "electric"))]
        )
        
        let jsonData = try JSONEncoder().encode(mockPokemon)
        mockSession.mockData = jsonData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co/api/v2/pokemon/25")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // 1回目の検索
        let result1 = try await api.searchPokemon(id: "25")
        
        // モックデータをクリア
        mockSession.mockData = nil
        mockSession.mockResponse = nil
        
        // 2回目の検索（キャッシュから取得されるはず）
        let result2 = try await api.searchPokemon(id: "25")
        
        // 検証
        #expect(result1.id == result2.id)
        #expect(result1.name == result2.name)
        #expect(mockSession.mockData == nil) // キャッシュから取得されたため、新しいリクエストは行われていない
    }
}
