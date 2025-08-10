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
    var coverImageData: Driver<Data> { get }
    var name: Driver<String> { get }
    var genresNames: Driver<String> { get }
    var summary: Driver<String> { get }
    var platformsImagesDatas: Driver<[Data]> { get }
}

class GameCellViewModel: GameCellViewModelProtocol {
    private let game: Game
    
    private let networkManager = NetworkManager.shared
    
    var coverImageData: Driver<Data> {
        guard let imageUrlString = game.cover?.imageID else { return .just(Data()) }
        return networkManager.fetchImage(by: imageUrlString, of: .coverSmall)
            .asDriver(onErrorJustReturn: Data())
    }
    
    var name: Driver<String> {
        Driver.just(game.name)
    }
    
    var genresNames: Driver<String> {
        let items = game.genres?.compactMap { $0.name } ?? []
        return .just(items.joined(separator: ", "))
    }
    
    var summary: Driver<String> {
        Driver.just(game.summary ?? String(localized: "No summary was provided for the game"))
    }
    
    var platformsImagesDatas: Driver<[Data]> {
        guard let imagesUrls = game.platforms?.compactMap({ $0.platformLogo?.imageID }) else { return .just([]) }
        let imageObservables = imagesUrls.map { urlString in
            networkManager.fetchImage(by: urlString, of: .thumb)
                .asObservable()
                .catchAndReturn(Data())
        }
        return Observable.zip(imageObservables)
            .asDriver(onErrorJustReturn: [])
    }
    
    init(game: Game) {
        self.game = game
    }
}
