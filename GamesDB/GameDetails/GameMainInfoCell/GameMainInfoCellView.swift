//
//  GameMainInfoCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class GameMainInfoCellView: UITableViewCell {
    private var viewModel: GameCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let platformsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
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
    
    func bind(to viewModel: GameCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.coverImageData
            .drive(onNext: { [weak self] imageData in
                .drive(onNext: { [weak self] imageData in
                    if imageData.count > 0 {
                        self?.coverImageView.image = UIImage(data: imageData)
                    } else {
                        self?.coverImageView.image = UIImage(systemName: "xmark.circle")
                        self?.coverImageView.backgroundColor = .systemGray
                        self?.coverImageView.tintColor = .white
                        self?.coverImageView.contentMode = .center
                    }
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.name
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.genresNames
            .drive(genresLabel.rx.text)
            .disposed(by: disposeBag)
        
        #warning("Implement rating and platforms in viewModel")
    }
    
    private func setupUI() {
        coverImageView.snp.makeConstraints { make in
            make.width.equalTo(155)
            make.height.equalTo(220)
        }
        coverImageView.layer.cornerRadius = 16
        coverImageView.layer.masksToBounds = true
        
        let nameToPlatformsStackView = UIStackView(arrangedSubviews: [titleLabel, genresLabel, platformsLabel])
        nameToPlatformsStackView.axis = .vertical
        nameToPlatformsStackView.spacing = 8
        nameToPlatformsStackView.alignment = .fill
        nameToPlatformsStackView.distribution = .equalSpacing
        
        let verticalStackView = UIStackView(arrangedSubviews: [nameToPlatformsStackView, ratingLabel])
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fillProportionally
        
        let coverToDataStackView = UIStackView(arrangedSubviews: [coverImageView, verticalStackView])
        coverToDataStackView.axis = .horizontal
        coverToDataStackView.spacing = 8
        coverToDataStackView.distribution = .equalSpacing
        coverToDataStackView.alignment = .fill
        
        contentView.addSubview(coverToDataStackView)
    }
}
