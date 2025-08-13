//
//  GameDetailsViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import Foundation
import RxCocoa

enum GameDetailSection: Int, CaseIterable {
    case mainInfo = 0
    case summary
    case videos
    case releaseDates
    case ageRatings
    case similarGames
    
    var title: String? {
        switch self {
        case .mainInfo: nil
        case .summary: String(localized: "Summary")
        case .videos: String(localized: "Videos")
        case .releaseDates: String(localized: "Release Dates")
        case .ageRatings: String(localized: "Age Ratings")
        case .similarGames: String(localized: "Similar Games")
        }
    }
}

protocol GameDetailsViewModelProtocol {
    var game: Game { get }
    
    var mainInfo: Driver<GameCellViewModelProtocol> { get }
    var summary: Driver<String> { get }
    var videos: Driver<[VideoCellViewModelProtocol]?> { get }
    var releaseDates: Driver<[ReleaseDateCellViewModelProtocol]?> { get }
    var ageRatings: Driver<[String]?> { get }
    var similarGames: Driver<[GameCellViewModelProtocol]?> { get }
}
