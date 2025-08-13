//
//  VideoCellViewModel.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 13.08.2025.
//

import Foundation
import RxCocoa

protocol VideoCellViewModelProtocol {
    var videoCoverData: Driver<Data> { get }
    var videoTitle: Driver<String> { get }
}
