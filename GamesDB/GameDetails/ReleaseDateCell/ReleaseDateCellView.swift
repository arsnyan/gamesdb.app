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
    static let reuseIdentifier = "ReleaseDateCellView"
    
    private var viewModel: ReleaseDateCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let platformsContainer: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        // Placeholder
        label.text = "--"
        label.textColor = .label
        label.numberOfLines = 1
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
        super.prepareForReuse()
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if lastLayoutWidth != bounds.width, let viewModel = viewModel {
            lastLayoutWidth = bounds.width
            
            viewModel.platformNames
                .drive(onNext: { [weak self] platforms in
                    self?.setupPlatformLabels(with: platforms)
                })
                .disposed(by: DisposeBag())
        }
    }
    
    private var lastLayoutWidth: CGFloat = 0
    
    func bind(to viewModel: ReleaseDateCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.country
            .drive(countryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.platformNames
            .drive(onNext: { [weak self] platforms in
                guard let self else { return }
                
                self.platformsContainer.subviews.forEach { $0.removeFromSuperview() }
                self.setupPlatformLabels(with: platforms)
                self.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        viewModel.releaseDate
            .drive(onNext: { [weak self] dateText in
                guard let self = self else { return }
                
                if dateText.isEmpty {
                    self.releaseDateLabel.text = "--"
                } else {
                    self.releaseDateLabel.text = dateText
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        let platformsDateStackView = UIStackView(arrangedSubviews: [platformsContainer, releaseDateLabel])
        platformsDateStackView.axis = .vertical
        platformsDateStackView.spacing = 8
        platformsDateStackView.distribution = .fill
        platformsDateStackView.alignment = .fill
        
        // Make platformsDateStackView take up available space
        platformsDateStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [countryLabel, platformsDateStackView])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    private func setupPlatformLabels(with platforms: [String]) {
        let horizontalSpacing: CGFloat = 8
        let verticalSpacing: CGFloat = 8
        
        platformsContainer.snp.removeConstraints()
        
        let estimatedMaxWidth = UIScreen.main.bounds.width - 100
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for platformName in platforms {
            let platformView = createPlatformLabel(with: platformName)
            platformsContainer.addSubview(platformView)
            
            let size = platformView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            if currentX + size.width > estimatedMaxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }
            
            platformView.frame = CGRect(x: currentX, y: currentY, width: size.width, height: size.height)
            
            currentX += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
        
        let totalHeight = currentY + rowHeight
        platformsContainer.snp.makeConstraints { make in
            make.height.equalTo(totalHeight > 0 ? totalHeight : 30) // Minimum height if no platforms
        }
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
