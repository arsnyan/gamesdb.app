//
//  SectionHeaderView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 12.08.2025.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .natural
        label.textColor = .systemGray
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)
        
        let separator = UIView()
        separator.backgroundColor = .separator
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.bottom.equalTo(separator.snp.top).offset(-8)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(with title: String, and systemIconName: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: systemIconName)
    }
}
