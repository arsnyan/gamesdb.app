//
//  IconNameViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation
import RxCocoa

protocol IconNameViewModelProtocol {
    var name: Driver<String> { get }
    var imageData: Driver<Data> { get }
}

class IconNameViewModel<T: NamedWithImageIdentifiable>: IconNameViewModelProtocol {
    private let networkManager = NetworkManager.shared
    private let model: NamedWithImageIdentifiable
    
    var name: Driver<String> {
        Driver.just(model.name)
    }
    
    var imageData: Driver<Data> {
        guard let imageId = model.logo?.imageID else { return .just(Data()) }
        return networkManager.fetchImageFromIGDB(by: imageId, of: .thumb)
            .asDriver(onErrorDriveWith: .empty())
    }
    
    init(model: NamedWithImageIdentifiable) {
        self.model = model
    }
}
