//
//  IconNameCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class IconNameCellView: UICollectionViewCell {
    static let identifier = "IconWithNameCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    private var viewModel: IconNameViewModelProtocol?
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
    }
    
    func bind(to viewModel: IconNameViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.name
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.imageData
            .drive { [weak self] imageData in
                self?.iconImageView.image = UIImage(data: imageData)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        iconImageView.layer.cornerRadius = 25
        iconImageView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, nameLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
