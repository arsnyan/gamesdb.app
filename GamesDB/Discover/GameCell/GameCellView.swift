//
//  GameCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GameCellView: UICollectionViewCell {
    static let reuseIdentifier = "GameCell"
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .systemGray
        label.numberOfLines = 1
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let platformsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = coverImageView.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()
    
    private var viewModel: GameCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        viewModel = nil
        
        loadingIndicator.startAnimating()
        
        coverImageView.image = nil
    }
    
    func bind(to viewModel: GameCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.coverImageData
            .drive(onNext: { [weak self] imageData in
                if imageData.count > 0 {
                    self?.coverImageView.image = UIImage(data: imageData)
                } else {
                    self?.coverImageView.image = UIImage(systemName: "xmark.circle")
                    self?.coverImageView.backgroundColor = .systemGray
                    self?.coverImageView.tintColor = .white
                    self?.coverImageView.contentMode = .center
                }
                
                self?.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        viewModel.name
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.genresNames
            .drive(genresLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.summary
            .drive(summaryLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.platformsImagesDatas
            .drive(onNext: { [weak self] datas in
                guard let self else { return }
                self.platformsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                
                datas.forEach { data in
                    let platformImageView = UIImageView(image: UIImage(data: data))
                    platformImageView.contentMode = .scaleAspectFit
                    platformImageView.snp.makeConstraints { make in
                        make.width.equalTo(30)
                        make.height.equalTo(30)
                    }
                    self.platformsStackView.addArrangedSubview(platformImageView)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        coverImageView.layer.cornerRadius = 16
        coverImageView.layer.masksToBounds = true
        
        let verticalStackView = UIStackView(arrangedSubviews: [nameLabel, genresLabel, summaryLabel, platformsStackView])
        verticalStackView.alignment = .leading
        verticalStackView.distribution = .fill
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .systemGray
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.snp.makeConstraints { make in
            make.width.equalTo(8)
        }
        
        let finalStackView = UIStackView(arrangedSubviews: [coverImageView, verticalStackView, arrowImageView])
        finalStackView.axis = .horizontal
        finalStackView.spacing = 8
        finalStackView.distribution = .fill
        finalStackView.alignment = .fill
        contentView.addSubview(finalStackView)
        
        coverImageView.snp.makeConstraints { make in
            make.width.equalTo(coverImageView.snp.height).multipliedBy(0.7)
            make.height.equalToSuperview()
        }
        
        finalStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(0)
        }
    }
}
