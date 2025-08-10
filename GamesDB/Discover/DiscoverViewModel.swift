//
//  DiscoverViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

enum SectionType: Int, CaseIterable {
    case companies = 0
    case gameEngines = 1
    case popularGames = 2
    
    var title: String {
        switch self {
        case .companies:
            String(localized: "Companies")
        case .gameEngines:
            String(localized: "Game Engines")
        case .popularGames:
            String(localized: "Popular Games")
        }
    }
    
    var iconName: String {
        switch self {
        case .companies:
            "building.2"
        case .gameEngines:
            "cpu"
        case .popularGames:
            "gamecontroller"
        }
    }
}

protocol DiscoverViewModelProtocol {
    var companyCellViewModels: Driver<[IconNameViewModelProtocol]> { get }
    var gameEngineCellViewModels: Driver<[IconNameViewModelProtocol]> { get }
    var gameCellViewModels: Driver<[GameCellViewModelProtocol]> { get }
    var isLoading: Driver<Bool> { get }
    var error: Driver<Error?> { get }
    
    func loadInitialData()
    func loadMoreGames()
    func refreshData()
}

class DiscoverViewModel: DiscoverViewModelProtocol {
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    
    private let companyCellViewModelsRelay = BehaviorRelay<[IconNameViewModelProtocol]>(value: [])
    private let gameEngineCellViewModelsRelay = BehaviorRelay<[IconNameViewModelProtocol]>(value: [])
    private let gameCellViewModelsRelay = BehaviorRelay<[GameCellViewModelProtocol]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<Error?>(value: nil)
    
    private var currentGamesPage = 1
    private var canLoadMoreGames = true
    private let pageSize = 10
    
    var companyCellViewModels: Driver<[IconNameViewModelProtocol]> {
        companyCellViewModelsRelay.asDriver()
    }
    
    var gameEngineCellViewModels: Driver<[IconNameViewModelProtocol]> {
        gameEngineCellViewModelsRelay.asDriver()
    }
    
    var gameCellViewModels: Driver<[GameCellViewModelProtocol]> {
        gameCellViewModelsRelay.asDriver()
    }
    
    var isLoading: Driver<Bool> {
        isLoadingRelay.asDriver()
    }
    
    var error: Driver<Error?> {
        errorRelay.asDriver()
    }
    
    func loadInitialData() {
        isLoadingRelay.accept(true)
        errorRelay.accept(nil)
        
        let companiesObservable = networkManager.fetchCompanies(at: 1)
        let gameEnginesObservable = networkManager.fetchGameEngines(at: 1)
        let gamesObservable = networkManager.fetchGames(at: 1)
        
        Observable.zip(companiesObservable, gameEnginesObservable, gamesObservable)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (companies, engines, games) in
                    let companyCellVMs = companies.map { IconNameViewModel<Company>(model: $0) }
                    let engineCellVMs = engines.map { IconNameViewModel<GameEngine>(model: $0) }
                    let gameCellVMs = games.map { GameCellViewModel(game: $0) }
                    
                    self?.companyCellViewModelsRelay.accept(companyCellVMs)
                    self?.gameEngineCellViewModelsRelay.accept(engineCellVMs)
                    self?.gameCellViewModelsRelay.accept(gameCellVMs)
                    
                    self?.currentGamesPage = 1
                    self?.canLoadMoreGames = games.count >= self?.pageSize ?? 0
                    self?.isLoadingRelay.accept(false)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.isLoadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func loadMoreGames() {
        guard canLoadMoreGames, !isLoadingRelay.value else { return }
        let nextPage = currentGamesPage + 1
        isLoadingRelay.accept(true)
        
        networkManager.fetchGames(at: nextPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] newGames in
                    guard let self else { return }
                    let currentGameCellVMs = gameCellViewModelsRelay.value
                    let newGameCellVMs = newGames.map { GameCellViewModel(game: $0) }
                    let updatedGameCellVMs = currentGameCellVMs + newGameCellVMs
                    
                    gameCellViewModelsRelay.accept(updatedGameCellVMs)
                    currentGamesPage = nextPage
                    canLoadMoreGames = newGames.count >= pageSize
                    isLoadingRelay.accept(false)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.isLoadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func refreshData() {
        currentGamesPage = 1
        canLoadMoreGames = true
        loadInitialData()
    }
}
