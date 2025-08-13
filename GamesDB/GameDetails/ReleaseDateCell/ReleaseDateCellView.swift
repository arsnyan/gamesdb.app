//
//  ReleaseDateCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ReleaseDateCellView: UITableViewCell {
    private var viewModel: ReleaseDateCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    
    private let platformsLabels: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
    func bind(to viewModel: ReleaseDateCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.country
            .drive(countryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.platformNames
            .drive(onNext: { [weak self] platforms in
                guard let self else { return }
                
                platforms.forEach { platformName in
                    self.platformsLabels.addArrangedSubview(
                        self.createPlatformLabel(with: platformName)
                    )
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.releaseDate
            .drive(releaseDateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        let platformsDateStackView = UIStackView(arrangedSubviews: [platformsLabels, releaseDateLabel])
        platformsDateStackView.axis = .vertical
        platformsDateStackView.spacing = 8
        platformsDateStackView.distribution = .equalSpacing
        platformsDateStackView.alignment = .fill
        
        let stackView = UIStackView(arrangedSubviews: [countryLabel, platformsDateStackView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
    }
    
    private func createPlatformLabel(with name: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8
        
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 14)
        
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
        
        return container
    }
}
