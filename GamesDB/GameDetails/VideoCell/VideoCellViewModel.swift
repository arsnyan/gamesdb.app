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
    var videoId: String { get }
}

class VideoCellViewModel: VideoCellViewModelProtocol {
    private let video: Video
    
    private let networkManager = NetworkManager.shared
    
    var videoCoverData: Driver<Data> {
        guard let url = URL(string: "https://img.youtube.com/vi/\(video.videoID)/0.jpg") else {
            return Driver.just(Data())
        }
        
        return networkManager.fetchImage(from: url)
            .asDriver(onErrorJustReturn: Data())
    }
    
    var videoTitle: Driver<String> {
        Driver.just(video.name ?? String(localized: "Title not specified"))
    }
    
    var videoId: String {
        video.videoID
    }
    
    init(video: Video) {
        self.video = video
    }
}
