//
//  VideoCellView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class VideoCellView: UITableViewCell {
    private var viewModel: VideoCellViewModelProtocol?
    private var disposeBag = DisposeBag()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
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
    
    func bind(to viewModel: VideoCellViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.videoTitle
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.videoCoverData
            .drive(onNext: { [weak self] data in
                if data.count > 0 {
                    self?.coverImageView.image = UIImage(data: data)
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
            make.height.equalTo(108)
            make.width.equalTo(192)
        }
        coverImageView.layer.cornerRadius = 16
        coverImageView.layer.masksToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [coverImageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        contentView.addSubview(stackView)
    }
}

