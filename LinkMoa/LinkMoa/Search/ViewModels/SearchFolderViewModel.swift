//
//  SearchFolderViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/25.
//

import Foundation

protocol SearchFolderViewModelOutputs {
    var searchedFolders: Observable<[SearchFolder.Result]> { get }
    var folderCount: Observable<Int> { get }

}

protocol SearchFolderViewModelInputs {
    func searchFolder(word: String, page: Int, isMine: Int)
}

protocol SearchFolderViewModelViewModelType {
    var inputs: SearchFolderViewModelInputs { get }
    var outputs: SearchFolderViewModelOutputs { get }
}

final class SearchFolderViewModel: SearchFolderViewModelOutputs, SearchFolderViewModelInputs, SearchFolderViewModelViewModelType {

    init() {
        self.surfingManager = SurfingManager()
    }
    private let surfingManager: SurfingManager
    var searchedFolders: Observable<[SearchFolder.Result]> = Observable([])

    var folderCount: Observable<Int> = Observable(0)

    
    var inputs: SearchFolderViewModelInputs { return self }
    var outputs: SearchFolderViewModelOutputs { return self }
    

    func searchFolder(word: String, page: Int, isMine: Int) {
        //0: 전체검색, 1: 나의검색
        let params: [String: Any] = ["word": word,
                                     "page": page,
                                     "limit": Constant.pageLimit,
                                     "isMyFolders": isMine]


        surfingManager.searchFolder(params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
                self.folderCount.value = response.resultCount
                if let data = response.result {
                    self.searchedFolders.value = data
                } else {
                    self.searchedFolders.value = []
                }
            }
        }
    }
}
