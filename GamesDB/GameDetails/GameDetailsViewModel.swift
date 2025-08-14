//
//  GameDetailsViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import Foundation
import RxCocoa
import RxSwift

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

class GameDetailsViewModel: GameDetailsViewModelProtocol {
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    
    let game: Game
    
    var mainInfo: Driver<GameCellViewModelProtocol> {
        Driver.just(GameCellViewModel(game: game))
    }
    
    var summary: Driver<String> {
        Driver.just(game.summary ?? String(localized: "No summary available"))
    }

    var videos: Driver<[VideoCellViewModelProtocol]?> {
        guard let gameVideos = game.videos, !gameVideos.isEmpty else {
            return Driver.just(nil)
        }
        
        let videoViewModels = gameVideos.map { VideoCellViewModel(video: $0) }
        return Driver.just(videoViewModels)
    }

    var releaseDates: Driver<[ReleaseDateCellViewModelProtocol]?> {
        guard let dates = game.releaseDates, !dates.isEmpty else {
            return Driver.just(nil)
        }
        
        // Group release dates by region and date
        var groupedDates: [String: [ReleaseDate]] = [:]
        
        for releaseDate in dates {
            // Create a key combining region and date (or use the human-readable date string if date is nil)
            // The human property from ReleaseDate contains a human-readable date string that's always available
            let dateKey = releaseDate.date != nil ? String(releaseDate.date!) : releaseDate.human
            let key = "\(releaseDate.releaseRegion.region.rawValue)_\(dateKey)"
            
            if groupedDates[key] == nil {
                groupedDates[key] = []
            }
            groupedDates[key]?.append(releaseDate)
        }
        
        // Create view models for each group
        let releaseDatesViewModels = groupedDates.values.map { releaseDates in
            // All dates in this group have the same region and date, so we can use the first one
            // for the region and date information
            let firstReleaseDate = releaseDates.first!
            
            // Collect all platforms for this region and date
            let platforms = releaseDates.map { $0.platform }
            
            return ReleaseDateCellViewModel(releaseDateModel: firstReleaseDate, platforms: platforms)
        }
        
        return Driver.just(releaseDatesViewModels)
    }

    var ageRatings: Driver<[String]?> {
        guard let ratings = game.ageRatings, !ratings.isEmpty else {
            return Driver.just(nil)
        }
        
        let ratingString = ratings.map { ageRating in
            "\(ageRating.ratingCategory.organization.name): \(ageRating.ratingCategory.rating)"
        }
        return Driver.just(ratingString)
    }

    var similarGames: Driver<[GameCellViewModelProtocol]?> {
        guard let similarGameIds = game.similarGames, !similarGameIds.isEmpty else {
            return Driver.just(nil)
        }
        
        return fetchSimilarGames(ids: similarGameIds)
            .map { games in
                games.map { GameCellViewModel(game: $0) }
            }
            .asDriver(onErrorJustReturn: nil)
    }
    
    init(game: Game) {
        self.game = game
    }
    
    private func fetchSimilarGames(ids: [Int]) -> Observable<[Game]> {
        let idsString = ids.map(String.init).joined(separator: ", ")
        let searchQuery = "where id = (\(idsString)"
        
        return networkManager.fetchGames(at: 0, with: searchQuery)
    }
}
