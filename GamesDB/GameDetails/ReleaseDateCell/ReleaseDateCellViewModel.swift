//
//  ReleaseDateCellViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import Foundation
import RxCocoa
import RxSwift

protocol ReleaseDateCellViewModelProtocol {
    var country: Driver<String> { get }
    var platformNames: Driver<[String]> { get }
    var releaseDate: Driver<String> { get }
}

class ReleaseDateCellViewModel: ReleaseDateCellViewModelProtocol {
    private let releaseDateModel: ReleaseDate
    private let platforms: [Platform]
    
    var country: Driver<String> {
        Driver.just(releaseDateModel.releaseRegion.region.representableFlag)
    }
    
    var platformNames: Driver<[String]> {
        Driver.just(platforms.compactMap(\.name))
    }
    
    var releaseDate: Driver<String> {
        guard let dateInterval = releaseDateModel.date else {
            if !releaseDateModel.human.isEmpty {
                return Driver.just(releaseDateModel.human)
            }
            
            return Driver.just(String(localized: "TBD"))
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(dateInterval))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        
        let formattedDate = dateFormatter.string(from: date)
        
        if formattedDate.isEmpty {
            return Driver.just(String(localized: "Unknown Date"))
        }
        
        return Driver.just(formattedDate)
    }
    
    init(releaseDateModel: ReleaseDate, platforms: [Platform]) {
        self.releaseDateModel = releaseDateModel
        self.platforms = platforms
    }
}
