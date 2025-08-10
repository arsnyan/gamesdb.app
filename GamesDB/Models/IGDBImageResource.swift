//
//  Logo.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation

struct IGDBImageResource: Codable {
    let id: Int
    let imageID: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageID = "image_id"
    }
}

struct IGDBImageResourceQuery {
    static let fields = [
        "image_id"
    ]
}

