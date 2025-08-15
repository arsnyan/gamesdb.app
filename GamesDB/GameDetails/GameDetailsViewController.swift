//
//  GameDetailsViewController.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SafariServices

struct GameDetailsSectionModel {
    let section: GameDetailSection
    var items: [GameDetailsItem]
}

enum GameDetailsItem {
    case mainInfo(GameCellViewModelProtocol)
    case summary(String)
    case videos([VideoCellViewModelProtocol])
    case releaseDate(ReleaseDateCellViewModelProtocol)
    case ageRating(String)
    case similarGames([GameCellViewModelProtocol])
}

extension GameDetailsSectionModel: SectionModelType {
    init(original: GameDetailsSectionModel, items: [GameDetailsItem]) {
        self = original
        self.items = items
    }
}

class GameDetailsViewController: UIViewController {
    private let viewModel: GameDetailsViewModelProtocol
    private var disposeBag = DisposeBag()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<GameDetailsSectionModel>(configureCell: { [weak self] dataSource, tableView, indexPath, item in
        self?.configureCell(for: item, at: indexPath) ?? UITableViewCell()
    }, titleForHeaderInSection: { dataSource, section in
        let sectionModel = dataSource[section]
        return sectionModel.items.isEmpty ? nil : sectionModel.section.title
    })
    
    init(viewModel: GameDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        bindViewModel()
    }
    
    private func setupView() {
        title = String(localized: "Details")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.register(GameMainInfoCellView.self, forCellReuseIdentifier: GameMainInfoCellView.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SummaryCell")
        tableView.register(HorizontalVideosView.self, forCellReuseIdentifier: HorizontalVideosView.reuseIdentifier)
        tableView.register(ReleaseDateCellView.self, forCellReuseIdentifier: ReleaseDateCellView.reuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AgeRatingCell")
        tableView.register(HorizontalSimilarGamesView.self, forCellReuseIdentifier: HorizontalSimilarGamesView.reuseIdentifier)
    }
    
    private func bindViewModel() {
        let mainInfoSection: Driver<GameDetailsSectionModel> = viewModel.mainInfo
            .map { mainInfoVM in
                GameDetailsSectionModel(
                    section: .mainInfo,
                    items: [GameDetailsItem.mainInfo(mainInfoVM)]
                )
            }
        
        let summarySection: Driver<GameDetailsSectionModel> = viewModel.summary
            .map { summaryText in
                GameDetailsSectionModel(
                    section: .summary,
                    items: summaryText.isEmpty ? [] : [GameDetailsItem.summary(summaryText)]
                )
            }
        
        let videosSection: Driver<GameDetailsSectionModel> = viewModel.videos
            .map { videoVMs in
                // There are videos? Then create a single item that contains all videos
                if let videoVMs = videoVMs, !videoVMs.isEmpty {
                    return GameDetailsSectionModel(
                        section: .videos,
                        items: [GameDetailsItem.videos(videoVMs)]
                    )
                } else {
                    return GameDetailsSectionModel(
                        section: .videos,
                        items: []
                    )
                }
            }
        
        let releaseDatesSection: Driver<GameDetailsSectionModel> = viewModel.releaseDates
            .map { releaseDateVMs in
                GameDetailsSectionModel(
                    section: .releaseDates,
                    items: (releaseDateVMs ?? []).map { GameDetailsItem.releaseDate($0) }
                )
            }
        
        let ageRatingsSection: Driver<GameDetailsSectionModel> = viewModel.ageRatings
            .map { ratings in
                GameDetailsSectionModel(
                    section: .ageRatings,
                    items: (ratings ?? []).map { GameDetailsItem.ageRating($0) }
                )
            }
        
        let similarGamesSection: Driver<GameDetailsSectionModel> = viewModel.similarGames
            .map { similarGameVMs in
                if let similarGameVMs = similarGameVMs, !similarGameVMs.isEmpty {
                    return GameDetailsSectionModel(
                        section: .similarGames,
                        items: [GameDetailsItem.similarGames(similarGameVMs)]
                    )
                } else {
                    return GameDetailsSectionModel(
                        section: .similarGames,
                        items: []
                    )
                }
            }
        
        let sections: Driver<[GameDetailsSectionModel]> = Driver.combineLatest(
            mainInfoSection,
            summarySection,
            videosSection,
            releaseDatesSection,
            ageRatingsSection,
            similarGamesSection
        ) { main, summary, videos, releaseDates, ageRatings, similarGames in
            [main, summary, videos, releaseDates, ageRatings, similarGames]
        }
        
        sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func configureCell(for item: GameDetailsItem, at indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .mainInfo(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GameMainInfoCellView.reuseIdentifier, for: indexPath) as? GameMainInfoCellView else {
                return UITableViewCell()
            }
            cell.bind(to: viewModel)
            return cell
        case .summary(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath)
            
            var config = cell.defaultContentConfiguration()
            config.text = text
            config.textProperties.numberOfLines = 0
            config.textProperties.lineBreakMode = .byWordWrapping
            cell.contentConfiguration = config
            cell.selectionStyle = .none
            
            return cell
        case .videos(let viewModels):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalVideosView.reuseIdentifier, for: indexPath) as? HorizontalVideosView else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.bind(to: viewModels)
            return cell
        case .releaseDate(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseDateCellView.reuseIdentifier, for: indexPath) as? ReleaseDateCellView else {
                return UITableViewCell()
            }
            cell.bind(to: viewModel)
            return cell
        case .ageRating(let rating):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgeRatingCell", for: indexPath)
            
            var config = cell.defaultContentConfiguration()
            config.text = rating
            config.textProperties.numberOfLines = 1
            config.textProperties.lineBreakMode = .byWordWrapping
            cell.contentConfiguration = config
            cell.selectionStyle = .none
            
            return cell
        case .similarGames(let viewModels):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HorizontalSimilarGamesView.reuseIdentifier, for: indexPath) as? HorizontalSimilarGamesView else {
                return UITableViewCell()
            }
            cell.bind(to: viewModels)
            return cell
        }
    }
}

extension GameDetailsViewController: HorizontalCellViewDelegate {
    func didSelectVideo(_ videoUrl: URL) {
        let safariVC = SFSafariViewController(url: videoUrl)
        present(safariVC, animated: true)
    }
}
