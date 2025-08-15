//
//  DiscoverViewController.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

struct DiscoverSectionModel {
    let section: DiscoverSection
    var items: [DiscoverItem]
}

enum DiscoverItem {
    case company(IconNameViewModelProtocol)
    case gameEngine(IconNameViewModelProtocol)
    case game(GameCellViewModelProtocol)
}

extension DiscoverItem: IdentifiableType, Equatable {
    var identity: String {
        switch self {
        case .company(let viewModel):
            "company-\(viewModel.id)"
        case .gameEngine(let viewModel):
            "engine\(viewModel.id)"
        case .game(let viewModel):
            "game-\(viewModel.id)"
        }
    }
    
    static func == (lhs: DiscoverItem, rhs: DiscoverItem) -> Bool {
        lhs.identity == rhs.identity
    }
}

extension DiscoverSectionModel: AnimatableSectionModelType {
    var identity: DiscoverSection {
        section
    }
    
    init(original: DiscoverSectionModel, items: [DiscoverItem]) {
        self = original
        self.items = items
    }
}

class DiscoverViewController: UIViewController {
    private let viewModel: DiscoverViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private var isLoadingMore = false
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<DiscoverSectionModel>(
        configureCell: { [weak self] dataSource, collectionView, indexPath, item in
        self?.configureCell(for: item, at: indexPath) ?? UICollectionViewCell()
    }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
        self?.configureHeader(for: kind, at: indexPath) ?? UICollectionReusableView()
    })
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()
    
    init(viewModel: DiscoverViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Discover"
        setupCollectionView()
        bindViewModel()
        setupRefreshControl()
        viewModel.loadInitialData()
    }
    
    private func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.register(IconNameCellView.self, forCellWithReuseIdentifier: "CompanyCell")
        collectionView.register(IconNameCellView.self, forCellWithReuseIdentifier: "GameEngineCell")
        collectionView.register(GameCellView.self, forCellWithReuseIdentifier: "GameCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
    }
    
    private func bindViewModel() {
        let companiesSection: Driver<DiscoverSectionModel> = viewModel.companyCellViewModels
            .map { companyVMs in
                DiscoverSectionModel(
                    section: .companies,
                    items: companyVMs.map({ DiscoverItem.company($0) })
                )
            }
        
        let enginesSection: Driver<DiscoverSectionModel> = viewModel.gameEngineCellViewModels
            .map { engineVMS in
                DiscoverSectionModel(
                    section: .gameEngines,
                    items: engineVMS.map({ DiscoverItem.gameEngine($0) })
                )
            }
        
        let gamesSection: Driver<DiscoverSectionModel> = viewModel.gameCellViewModels
            .map { gameVMs in
                DiscoverSectionModel(
                    section: .popularGames,
                    items: gameVMs.map({ DiscoverItem.game($0) })
                )
            }
        
        let sections: Driver<[DiscoverSectionModel]> = Driver.combineLatest(
            companiesSection,
            enginesSection,
            gamesSection
        ) { companies, engines, games in
            [companies, engines, games]
        }
        
        sections
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.gameCellViewModels
            .drive(onNext: { [weak self] _ in
                self?.isLoadingMore = false
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .filter { !$0 }
            .drive(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
                self?.isLoadingMore = false
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showError(error)
                print(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.navigationAction
            .drive(onNext: { [weak self] action in
                self?.handleNavigation(action)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleNavigation(_ action: NavigationAction) {
        switch action {
        case .showGameDetails(let game):
            let gameDetailsViewModel = GameDetailsViewModel(game: game)
            let gameDetailsVC = GameDetailsViewController(viewModel: gameDetailsViewModel)
            navigationController?.pushViewController(gameDetailsVC, animated: true)
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.viewModel.loadInitialData()
        }))
        present(alert, animated: true)
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let sectionType = DiscoverSection(rawValue: sectionIndex) else {
                return self?.createDefaultSection()
            }
            
            switch sectionType {
            case .companies, .gameEngines:
                return self?.createHorizontalSection()
            case .popularGames:
                return self?.createVerticalSection()
            }
        }
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(72))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createVerticalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(72))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createDefaultSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
    
    private func configureCell(for item: DiscoverItem, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .company(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCell", for: indexPath) as? IconNameCellView else {
                return UICollectionViewCell()
            }
            cell.bind(to: viewModel)
            return cell
        case .gameEngine(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameEngineCell", for: indexPath) as? IconNameCellView else {
                return UICollectionViewCell()
            }
            cell.bind(to: viewModel)
            return cell
        case .game(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameCellView.reuseIdentifier, for: indexPath) as? GameCellView else {
                return UICollectionViewCell()
            }
            cell.bind(to: viewModel)
            return cell
        }
    }
    
    private func configureHeader(for kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = DiscoverSection(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as! SectionHeaderView
        header.configure(with: sectionType.title, and: sectionType.iconName)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension DiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = DiscoverSection(rawValue: indexPath.section),
              sectionType == .popularGames else { return }
        
        viewModel.selectGame(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension DiscoverViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let popularGamesIndexPaths = indexPaths.filter { indexPath in
            guard let sectionType = DiscoverSection(rawValue: indexPath.section) else {
                return false
            }
            return sectionType == .popularGames
        }
        
        guard !popularGamesIndexPaths.isEmpty else { return }
        
        let currentItemsCount = dataSource.sectionModels.isEmpty ? 0 : dataSource.sectionModels[DiscoverSection.popularGames.rawValue].items.count
        
        let maxItemIndex = popularGamesIndexPaths.map(\.item).max() ?? 0
        
        if maxItemIndex >= currentItemsCount - 5 && !isLoadingMore {
            isLoadingMore = true
            viewModel.loadMoreGames()
        }
    }
}
