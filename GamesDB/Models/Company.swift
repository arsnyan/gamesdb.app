//
//  Company.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation

protocol NamedWithImageIdentifiable {
    var id: Int { get }
    var name: String { get }
    var logo: IGDBImageResource? { get }
}

// MARK: - Company
struct Company: Codable, NamedWithImageIdentifiable {
    let id: Int
    let developed: [Int]?
    let logo: IGDBImageResource?
    let name: String
    let published: [Int]?
}

struct CompanyQuery {
    static let fields = [
        "name",
        "published",
        "developed",
        "logo.image_id"
    ]
}
