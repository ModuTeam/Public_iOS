//
//  SearchLinkViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/24.
//

import Foundation

//MARK:- 폐기

protocol SearchLinkViewModelOutputs {
    var searchedLinks: Observable<[SearchLink.Result]> { get }
    var linkCount: Observable<Int> { get }
}

protocol SearchLinkViewModelInputs {
    func searchLink(word: String, page: Int, isMine: Int)
}

protocol SearchLinkViewModelType {
    var inputs: SearchLinkViewModelInputs { get }
    var outputs: SearchLinkViewModelOutputs { get }
}

class SearchLinkViewModel: SearchLinkViewModelInputs, SearchLinkViewModelOutputs, SearchLinkViewModelType {
    
    init() {
        self.surfingManager = SurfingManager()
    }
    private let surfingManager: SurfingManager
    var searchedLinks: Observable<[SearchLink.Result]> = Observable([])
    
    var inputs: SearchLinkViewModelInputs { return self }
    var outputs: SearchLinkViewModelOutputs { return self }
    var linkCount: Observable<Int> = Observable(0)
    
    func searchLink(word: String, page: Int, isMine: Int) {
        let params: [String: Any] = ["word": word,
                                     "page": page,
                                     "limit": Constant.pageLimit,
                                     "isMyFolders": isMine]

        surfingManager.searchLink(params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.searchedLinks.value = []
                DEBUG_LOG(error)
            case .success(let response):
                self.linkCount.value = response.resultCount
                if let data = response.result {
                    self.searchedLinks.value = data
                } else {
                    self.searchedLinks.value = []
                }
            }
        }
    }

}
