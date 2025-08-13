//
//  ReleaseDateCellViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import Foundation
import RxCocoa

protocol ReleaseDateCellViewModelProtocol {
    var country: Driver<String> { get }
    var platformNames: Driver<[String]> { get }
    var releaseDate: Driver<String> { get }
}
