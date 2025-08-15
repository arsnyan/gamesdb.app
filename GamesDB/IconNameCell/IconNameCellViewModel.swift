//
//  IconNameViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation
import RxCocoa

protocol IconNameViewModelProtocol {
    var id: Int { get }
    var name: Driver<String> { get }
    var imageData: Driver<Data> { get }
}

class IconNameViewModel<T: NamedWithImageIdentifiable>: IconNameViewModelProtocol {
    private let networkManager = NetworkManager.shared
    private let model: NamedWithImageIdentifiable
    
    private let cache = NSCache<NSString, NSData>()
    
    var id: Int {
        model.id
    }
    
    var name: Driver<String> {
        Driver.just(model.name)
    }
    
    var imageData: Driver<Data> {
        guard let imageId = model.logo?.imageID else { return .just(Data()) }
        
        let cacheKey = NSString(string: imageId)
        
        if let cachedData = cache.object(forKey: cacheKey) {
            return .just(cachedData as Data)
        } else {
            return networkManager.fetchImageFromIGDB(by: imageId, of: .thumb)
                .do(onNext: { [weak self] data in
                    self?.cache.setObject(data as NSData, forKey: cacheKey)
                })
                .asDriver(onErrorJustReturn: Data())
        }
    }
    
    init(model: NamedWithImageIdentifiable) {
        self.model = model
    }
}
