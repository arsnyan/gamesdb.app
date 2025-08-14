//
//  HorizontalVideosView.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HorizontalVideosView: UITableViewCell {
    static let reuseIdentifier = "HorizontalVideosView"
    
    private var viewModels: [VideoCellViewModelProtocol] = []
    private var disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 192, height: 150) // Adjust based on your video cell size
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(VideoCellView.self, forCellWithReuseIdentifier: VideoCellView.reuseIdentifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModels = []
        disposeBag = DisposeBag()
    }
    
    func bind(to viewModels: [VideoCellViewModelProtocol]) {
        self.viewModels = viewModels
        collectionView.reloadData()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(170) // Adjust based on your cell height + padding
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension HorizontalVideosView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCellView.reuseIdentifier, for: indexPath) as? VideoCellView else {
            return UICollectionViewCell()
        }
        
        let viewModel = viewModels[indexPath.item]
        cell.bind(to: viewModel)
        return cell
    }
}
