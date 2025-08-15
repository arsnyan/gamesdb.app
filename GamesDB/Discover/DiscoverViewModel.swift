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

enum DiscoverSection: Int, CaseIterable {
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
    var isLoadingMore: Driver<Bool> { get }
    var error: Driver<Error?> { get }
    var navigationAction: Driver<NavigationAction> { get }
    
    func loadInitialData()
    func loadMoreGames()
    func refreshData()
    func selectGame(at index: Int)
}

enum NavigationAction {
    case showGameDetails(Game)
}

class DiscoverViewModel: DiscoverViewModelProtocol {
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    
    private let companyCellViewModelsRelay = BehaviorRelay<[IconNameViewModelProtocol]>(value: [])
    private let gameEngineCellViewModelsRelay = BehaviorRelay<[IconNameViewModelProtocol]>(value: [])
    private let gameCellViewModelsRelay = BehaviorRelay<[GameCellViewModelProtocol]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let isLoadingMoreRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = BehaviorRelay<Error?>(value: nil)
    private let navigationActionSubject = PublishSubject<NavigationAction>()
    
    private var games: [Game] = []
    
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
    
    var isLoadingMore: Driver<Bool> {
        isLoadingMoreRelay.asDriver()
    }
    
    var error: Driver<Error?> {
        errorRelay.asDriver()
    }
    
    var navigationAction: Driver<NavigationAction> {
        navigationActionSubject.asDriver(onErrorDriveWith: .empty())
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
                    
                    self?.games = games
                    
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
        isLoadingMoreRelay.accept(true)
        
        networkManager.fetchGames(at: nextPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] newGames in
                    guard let self else { return }
                    let currentGameCellVMs = gameCellViewModelsRelay.value
                    let newGameCellVMs = newGames.map { GameCellViewModel(game: $0) }
                    let updatedGameCellVMs = currentGameCellVMs + newGameCellVMs
                    
                    gameCellViewModelsRelay.accept(updatedGameCellVMs)
                    
                    games.append(contentsOf: newGames)
                    
                    currentGamesPage = nextPage
                    canLoadMoreGames = newGames.count >= pageSize
                    isLoadingMoreRelay.accept(false)
                },
                onError: { [weak self] error in
                    self?.errorRelay.accept(error)
                    self?.isLoadingMoreRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func refreshData() {
        currentGamesPage = 1
        canLoadMoreGames = true
        loadInitialData()
    }
    
    func selectGame(at index: Int) {
        guard index < games.count else { return }
        let selectedGame = games[index]
        navigationActionSubject.onNext(.showGameDetails(selectedGame))
    }
}
