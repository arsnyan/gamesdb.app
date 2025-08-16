//
//  SimilarGameCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SimilarGameCellView: UICollectionViewCell {
    static let reuseIdentifier = "SimilarGameCellView"
    
    private var viewModel: GameCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 3
        label.textAlignment = .natural
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func bind(to viewModel: GameCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.name
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
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
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        coverImageView.snp.makeConstraints { make in
            make.width.equalTo(155)
            make.height.equalTo(220)
        }
        coverImageView.layer.cornerRadius = 16
        coverImageView.layer.masksToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [coverImageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
    }
}
