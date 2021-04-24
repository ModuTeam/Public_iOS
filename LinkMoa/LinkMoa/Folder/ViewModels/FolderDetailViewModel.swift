//
//  FolderDetailViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/11.
//

import Foundation

protocol FolderDetailViewModelOutputs {
    var folderDetail: Observable<FolderDetail.Result> { get }
    var links: Observable<[FolderDetail.Link]> { get }
    var tags: Observable<[FolderDetail.HashTag]> { get }
    var folderName: Observable<String> { get }
    var isShared: Observable<Bool> { get }
}

protocol FolderDetailViewModelInputs {
    func fetchFolderDetail(folderIndex index: Int)
    func removeFolder(folderIndex index: Int, completionHandler: @escaping ((Result<FolderResponse, Error>) -> ()))
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> ())
}

protocol FolderDetailViewModelType {
    var inputs: FolderDetailViewModelInputs { get }
    var outputs: FolderDetailViewModelOutputs { get }
}

final class FolderDetailViewModel: FolderDetailViewModelOutputs, FolderDetailViewModelInputs, FolderDetailViewModelType {

    private let myScallopManager = MyScallopManager()
    private let surfingManager = SurfingManager()


    var folderDetail: Observable<FolderDetail.Result> = Observable(FolderDetail.Result())
    var links: Observable<[FolderDetail.Link]> = Observable([])
    var tags: Observable<[FolderDetail.HashTag]> = Observable([])
    var folderName: Observable<String> = Observable("")
    var isShared: Observable<Bool> = Observable(false)
    
    var inputs: FolderDetailViewModelInputs { return self }
    var outputs: FolderDetailViewModelOutputs { return self }
    
    func fetchFolderDetail(folderIndex index: Int) {
        myScallopManager.fetchFolderDetail(folder: index, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let folderDetail):
                if let result = folderDetail.result, folderDetail.isSuccess {
                    self.folderDetail.value = result
                    self.links.value = result.linkList
                    self.tags.value = result.hashTagList
                    self.folderName.value = result.name
                    self.isShared.value = result.type == "public" ? true : false
                } else {
                    print("서버 에러")
                }
            case .failure(let error):
                print(error)
            }
        
        })
    }
    
    func removeFolder(folderIndex index: Int, completionHandler: @escaping ((Result<FolderResponse, Error>) -> ())) {
        myScallopManager.deleteFolder(folder: index, completion: completionHandler)
    }
    
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> ()) {
        myScallopManager.deleteLInk(link: index, completion: completionHandler) // 이름 수정해야함
    }
}
