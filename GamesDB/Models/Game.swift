//
//  Game.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation

// MARK: - Game
struct Game: Codable {
    let id: Int
    let cover: IGDBImageResource?
    let genres: [Genre]?
    let name: String
    let platforms: [Platform]?
    let releaseDates: [ReleaseDate]?
    let summary: String?
    let videos: [Video]?
    let similarGames: [Int]?
    let rating: Double?
    let ratingCount: Int?
    let ageRatings: [AgeRating]?

    enum CodingKeys: String, CodingKey {
        case id, cover, genres, name, platforms
        case releaseDates = "release_dates"
        case summary, videos
        case similarGames = "similar_games"
        case rating
        case ratingCount = "rating_count"
        case ageRatings = "age_ratings"
    }
}

// MARK: - AgeRating
struct AgeRating: Codable {
    let id: Int
    let ratingCategory: RatingCategory

    enum CodingKeys: String, CodingKey {
        case id
        case ratingCategory = "rating_category"
    }
}

// MARK: - RatingCategory
struct RatingCategory: Codable {
    let id: Int
    let rating: String
    let organization: Genre
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - Platform
struct Platform: Codable {
    let id: Int
    let name: String
    let platformLogo: IGDBImageResource?

    enum CodingKeys: String, CodingKey {
        case id, name
        case platformLogo = "platform_logo"
    }
}

// MARK: - ReleaseDate
struct ReleaseDate: Codable {
    let id: Int
    let human: String
    let releaseRegion: ReleaseRegion
    let platform: Platform
    let date: Int?

    enum CodingKeys: String, CodingKey {
        case id, human
        case releaseRegion = "release_region"
        case platform
        case date
    }
}

// MARK: - ReleaseRegion
struct ReleaseRegion: Codable {
    let id: Int
    let region: Region
}

enum Region: String, Codable {
    case asia = "asia"
    case australia = "australia"
    case brazil = "brazil"
    case china = "china"
    case europe = "europe"
    case japan = "japan"
    case northAmerica = "north_america"
    case worldwide = "worldwide"
    
    var representableFlag: String {
        switch self {
        case .asia: "🇵🇭"
        case .australia: "🇦🇺"
        case .brazil: "🇧🇷"
        case .china: "🇨🇳"
        case .europe: "🇪🇺"
        case .japan: "🇯🇵"
        case .northAmerica: "🇺🇸"
        case .worldwide: "🌍"
        }
    }
}

// MARK: - Video
struct Video: Codable {
    let id: Int
    let name: String
    let videoID: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case videoID = "video_id"
    }
}

// MARK: - Query Builder
struct GameQuery {
    static let fields = [
        "name",
        "cover.image_id",
        "platforms.name",
        "platforms.platform_logo.image_id",
        "summary",
        "similar_games",
        "genres.name",
        "release_dates.date",
        "release_dates.human",
        "release_dates.release_region.region",
        "release_dates.platform.name",
        "rating",
        "rating_count",
        "age_ratings.rating_category.rating",
        "age_ratings.rating_category.organization.name",
        "videos.video_id",
        "videos.name"
    ]
    
    static func build(limit: Int, offset: Int) -> String {
        """
        fields \(fields.joined(separator: ","));
        limit \(limit);
        offset \(offset);
        """
    }
}
