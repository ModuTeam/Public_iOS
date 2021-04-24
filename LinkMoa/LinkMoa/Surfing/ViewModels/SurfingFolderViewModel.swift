//
//  SurfingFolderViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/11.
//

import Foundation

protocol SurfingFolderViewModelOutputs {
    var topTenFolders: Observable<[TopTenFolder.Result]> { get }
    var likedFolders: Observable<[LikedFolder.Result]> { get }
    var usersFolders: Observable<[UsersFolder.Result]> { get }
}

protocol SurfingFolderViewModelInputs {
    func fetchTopTenFolder()
    func fetchLikedFolders(word: String?, page: Int)
    func fetchUsersFolders(user: Int, page: Int)
    
}

protocol SurfingFolderViewModelType {
    var inputs: SurfingFolderViewModelInputs { get }
    var outputs: SurfingFolderViewModelOutputs { get }
}

final class SurfingFolderViewModel: SurfingFolderViewModelOutputs, SurfingFolderViewModelInputs, SurfingFolderViewModelType {
   
    
    
    init() {
        self.surfingManager = SurfingManager()
    }
    
    private let surfingManager: SurfingManager
    
    var inputs: SurfingFolderViewModelInputs { return self }
    var outputs: SurfingFolderViewModelOutputs { return self }
    
    var topTenFolders: Observable<[TopTenFolder.Result]> = Observable([])
    var likedFolders: Observable<[LikedFolder.Result]> = Observable([])
    var usersFolders: Observable<[UsersFolder.Result]> = Observable([])
    
    func fetchTopTenFolder() {
        surfingManager.fetchTopTenFolder { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
                let data = response.result
                self.topTenFolders.value = data
            }
        }
    }
    
    func fetchLikedFolders(word: String?, page: Int) {
        var params: [String: Any] = ["page" : page,
                                     "limit" : 200
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
    
    func fetchUsersFolders(user: Int, page: Int) {
        let params: [String: Any] = ["page" : page,
                                     "limit" : 100
        ]
        
        surfingManager.fetchUsersFolders(folder: user, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
                self.usersFolders.value = []
            case .success(let response):
                self.usersFolders.value = response.result
            }
        }
    }
}

