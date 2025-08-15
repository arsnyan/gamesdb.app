//
//  GameCellViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol GameCellViewModelProtocol {
    var id: Int { get }
    var coverImageData: Driver<Data> { get }
    var name: Driver<String> { get }
    var genresNames: Driver<String> { get }
    var summary: Driver<String> { get }
    var platformsImagesDatas: Driver<[Data]> { get }
    var platformsNames: Driver<String> { get }
    var rating: Driver<String> { get }
    
    var game: Game { get }
}

class GameCellViewModel: GameCellViewModelProtocol {
    private(set) var game: Game
    
    private let networkManager = NetworkManager.shared
    
    private let cache = NSCache<NSString, NSData>()
    
    var id: Int {
        game.id
    }
    
    var coverImageData: Driver<Data> {
        guard let imageId = game.cover?.imageID else { return .just(Data()) }
        
        let cacheKey = NSString(string: imageId)
        
        if let cachedData = cache.object(forKey: cacheKey) {
            return .just(cachedData as Data)
        } else {
            return networkManager.fetchImageFromIGDB(by: imageId, of: .coverSmall)
                .do(onNext: { [weak self] data in
                    self?.cache.setObject(data as NSData, forKey: cacheKey)
                })
                .asDriver(onErrorJustReturn: Data())
        }
    }
    
    var name: Driver<String> {
        Driver.just(game.name)
    }
    
    var genresNames: Driver<String> {
        let items = game.genres?.compactMap { $0.name } ?? []
        return .just(items.joined(separator: ", "))
    }
    
    var summary: Driver<String> {
        Driver.just(game.summary ?? String(localized: "No summary available"))
    }
    
    var platformsImagesDatas: Driver<[Data]> {
        guard let imagesUrls = game.platforms?.compactMap({ $0.platformLogo?.imageID }) else { return .just([]) }
        let imageObservables = imagesUrls.map { urlString in
            networkManager.fetchImageFromIGDB(by: urlString, of: .thumb)
                .asObservable()
                .catchAndReturn(Data())
        }
        return Observable.zip(imageObservables)
            .asDriver(onErrorJustReturn: [])
    }
    
    var platformsNames: Driver<String> {
        let names = game.platforms?.compactMap { $0.name }
        return Driver.just(names?.joined(separator: ", ") ?? String(localized: "No platforms specified"))
    }
    
    var rating: Driver<String> {
        guard let rating = game.rating,
              let ratingCount = game.ratingCount else {
            return Driver.just("No rating")
        }
        
        let formattedRating = String(format: "%.1f", rating / 10)
        let formatString = String(localized: "%1$(rating)@/10 from %2$(ratingCount)lld responses")
        return Driver.just(String(format: formatString, formattedRating, ratingCount))
    }
    
    init(game: Game) {
        self.game = game
    }
}
