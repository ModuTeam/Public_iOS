//
//  FolderDetailViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/11.
//

import Foundation

protocol FolderDetailViewModelOutputs {
    var folderDetail: LMObservable<FolderDetail.Result> { get }
    var links: LMObservable<[FolderDetail.Link]> { get }
    var tags: LMObservable<[FolderDetail.HashTag]> { get }
    var folderName: LMObservable<String> { get }
    var isShared: LMObservable<Bool> { get }
}

protocol FolderDetailViewModelInputs {
    func fetchFolderDetail(folderIndex index: Int)
    func removeFolder(folderIndex index: Int, completionHandler: @escaping (Result<FolderResponse, Error>) -> Void)
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> Void)
}

protocol FolderDetailViewModelType {
    var inputs: FolderDetailViewModelInputs { get }
    var outputs: FolderDetailViewModelOutputs { get }
}

final class FolderDetailViewModel: FolderDetailViewModelOutputs, FolderDetailViewModelInputs, FolderDetailViewModelType {

    private let myScallopManager = MyScallopManager()
    private let surfingManager = SurfingManager()

    var folderDetail: LMObservable<FolderDetail.Result> = LMObservable(FolderDetail.Result())
    var links: LMObservable<[FolderDetail.Link]> = LMObservable([])
    var tags: LMObservable<[FolderDetail.HashTag]> = LMObservable([])
    var folderName: LMObservable<String> = LMObservable("")
    var isShared: LMObservable<Bool> = LMObservable(false)
    
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
    
    func removeFolder(folderIndex index: Int, completionHandler: @escaping (Result<FolderResponse, Error>) -> Void) {
        myScallopManager.deleteFolder(folder: index, completion: completionHandler)
    }
    
    func deleteLink(link index: Int, completionHandler: @escaping (Result<LinkResponse, Error>) -> Void) {
        myScallopManager.deleteLInk(link: index, completion: completionHandler) // 이름 수정해야함
    }
}
