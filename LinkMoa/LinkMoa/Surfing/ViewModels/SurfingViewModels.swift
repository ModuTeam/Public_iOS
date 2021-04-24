//
//  SurfingViewModels.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/09.
//

import Foundation

protocol SurfingViewModelOutputs {
    var likedFolders: Observable<[LikedFolder.Result]> { get }
    var topTenFolders: Observable<[TopTenFolder.Result]> { get }
    var todayFolders: Observable<[TodayFolder.Result]> { get }
}

protocol SurfingViewModelInputs {
    func fetchTopTenFolder()
    func fetchLikedFolders(word: String?, page: Int)
    func fetchTodayFolder()
    
}

protocol SurfingViewModelType {
    var inputs: SurfingViewModelInputs { get }
    var outputs: SurfingViewModelOutputs { get }
}

final class SurfingViewModel: SurfingViewModelOutputs, SurfingViewModelInputs, SurfingViewModelType {
    
    init() {
        self.surfingManager = SurfingManager()
    }
    
    private let surfingManager: SurfingManager
    
    var inputs: SurfingViewModelInputs { return self }
    var outputs: SurfingViewModelOutputs { return self }
    
    var topTenFolders: Observable<[TopTenFolder.Result]> = Observable([])
    var likedFolders: Observable<[LikedFolder.Result]> = Observable([])
    var todayFolders: Observable<[TodayFolder.Result]> = Observable([])
    
    func fetchTopTenFolder() {
        surfingManager.fetchTopTenFolder { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
                ///레이아웃 만들기 위해서 더미데이터 4개넣음
                self.topTenFolders.value = [.init(), .init(), .init(), .init()]
            case .success(let response):
                let data = response.result
                self.topTenFolders.value = data
            }
        }
    }
    
    func fetchLikedFolders(word: String?, page: Int) {
        var params: [String: Any] = ["page": page,
                                     "limit": Constant.pageLimit
        ]
        
        if let word = word {
            params["word"] = word
        }
        
        surfingManager.fetchLikedFolders(params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
                self.likedFolders.value = []
            case .success(let response):
                if let data = response.result {
                    self.likedFolders.value = data
                } else {
                    self.likedFolders.value = []
                }
            }
        }
    }
    
    func fetchTodayFolder() {
        surfingManager.fetchTodayFolder { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
                let data = response.result
                self.todayFolders.value = data
            }
        }
    }
}
