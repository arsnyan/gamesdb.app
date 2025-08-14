//
//  DiscoverViewController.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import UIKit
import RxSwift
import RxCocoa

class DiscoverViewController: UICollectionViewController {
    private let viewModel: DiscoverViewModelProtocol
    private let disposeBag = DisposeBag()
    
    private var companyCellViewModels: [IconNameViewModelProtocol] = []
    private var gameEngineCellViewModels: [IconNameViewModelProtocol] = []
    private var gameCellViewModels: [GameCellViewModelProtocol] = []
    private var isLoadingMore = false
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()
    
    init(viewModel: DiscoverViewModelProtocol) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        title = "Discover"
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(IconNameCellView.self, forCellWithReuseIdentifier: "CompanyCell")
        collectionView.register(IconNameCellView.self, forCellWithReuseIdentifier: "GameEngineCell")
        collectionView.register(GameCellView.self, forCellWithReuseIdentifier: "GameCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
    }
    
    private func bindViewModel() {
        viewModel.companyCellViewModels
            .drive(onNext: { [weak self] cellViewModels in
                self?.companyCellViewModels = cellViewModels
                self?.collectionView.reloadSections(IndexSet(integer: DiscoverSectionType.companies.rawValue))
            })
            .disposed(by: disposeBag)
        
        viewModel.gameEngineCellViewModels
            .drive(onNext: { [weak self] cellViewModels in
                self?.gameEngineCellViewModels = cellViewModels
                self?.collectionView.reloadSections(IndexSet(integer: DiscoverSectionType.gameEngines.rawValue))
            })
            .disposed(by: disposeBag)
        
        viewModel.gameCellViewModels
            .drive(onNext: { [weak self] cellViewModels in
                self?.gameCellViewModels = cellViewModels
                self?.collectionView.reloadSections(IndexSet(integer: DiscoverSectionType.popularGames.rawValue))
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.isLoadingMore = isLoading
                
                if !isLoading && self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
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
            guard let sectionType = DiscoverSectionType(rawValue: sectionIndex) else {
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
}

// MARK: - UICollectionViewDataSource
extension DiscoverViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DiscoverSectionType.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = DiscoverSectionType(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .companies:
            return companyCellViewModels.count
        case .gameEngines:
            return gameEngineCellViewModels.count
        case .popularGames:
            return gameCellViewModels.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = DiscoverSectionType(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .companies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCell", for: indexPath) as! IconNameCellView
            let cellViewModel = companyCellViewModels[indexPath.item]
            cell.bind(to: cellViewModel)
            return cell
        case .gameEngines:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameEngineCell", for: indexPath) as! IconNameCellView
            let cellViewModel = gameEngineCellViewModels[indexPath.item]
            cell.bind(to: cellViewModel)
            return cell
        case .popularGames:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as! GameCellView
            let cellViewModel = gameCellViewModels[indexPath.item]
            cell.bind(to: cellViewModel)
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = DiscoverSectionType(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        header.configure(with: sectionType.title, and: sectionType.iconName)
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionType = DiscoverSectionType(rawValue: indexPath.section),
              sectionType == .popularGames else { return }
        
        let itemsCount = gameCellViewModels.count
        if indexPath.item >= itemsCount - 5 && !isLoadingMore {
            viewModel.loadMoreGames()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = DiscoverSectionType(rawValue: indexPath.section),
              sectionType == .popularGames else { return }
        
        viewModel.selectGame(at: indexPath.item)
    }
}
