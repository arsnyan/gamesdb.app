//
//  DataManager.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func loadAccessToken() -> String? {
        guard let tokenInfoData = defaults.data(forKey: DataKeys.accessToken.rawValue) else { return nil }
        let tokenInfo = try! JSONDecoder().decode(TokenInfo.self, from: tokenInfoData)
        return Date() >= tokenInfo.expirationDate ? nil : tokenInfo.token
    }
    
    func saveAccessToken(_ token: String, expiresIn seconds: Int) {
        let encodedData = try! JSONEncoder().encode(TokenInfo(
            token: token,
            expirationDate: Date.init(timeIntervalSinceNow: TimeInterval(seconds))
        ))
        defaults.set(
            encodedData,
            forKey: DataKeys.accessToken.rawValue
        )
    }
}

enum DataKeys: String {
    case accessToken = "igdb_access_token"
}

private struct TokenInfo: Codable {
    let token: String
    let expirationDate: Date
}
