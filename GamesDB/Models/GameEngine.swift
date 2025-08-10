//
//  GameEngine.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation

struct GameEngine: Codable, NamedWithImageIdentifiable {
    let id: Int
    let name: String
    let companiesUsingIds: [Int]?
    let description: String?
    let logo: IGDBImageResource?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case companiesUsingIds = "companies"
        case description
        case logo
    }
}

struct GameEngineQuery {
    static let fields = [
        "companies",
        "description",
        "logo.image_id",
        "name"
    ]
}
