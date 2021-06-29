//
//  FolderViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/07.
//

import Foundation

enum FolderFetchType: Int {
    case current = 1 // 최신 순
    case name = 2 // 이름 순
    case old = 3 // 오래된 순
}

protocol FolderViewModelOutputs {
    var folders: LMObservable<[FolderList.Result]> { get }
}

protocol FolderViewModelInputs {
    func fetchFolders(completion: (() -> Void)?)
    func fetchFolderDetail(folderIndex index: Int, completionHandler: @escaping (Result<FolderDetail, Error>) -> Void)
    func removeFolder(folderIndex index: Int, completionHandler: @escaping ((Result<FolderResponse, Error>) -> Void))
}

protocol FolderViewModelType {
    var inputs: FolderViewModelInputs { get }
    var outputs: FolderViewModelOutputs { get }
}

final class FolderViewModel: FolderViewModelInputs, FolderViewModelOutputs, FolderViewModelType {
    
    private let myScallopManager = MyScallopManager()
    private let surfingManager = SurfingManager()
    
    var folderFetchType: FolderFetchType = .old
    var folders: LMObservable<[FolderList.Result]> = LMObservable([])
    
    var inputs: FolderViewModelInputs { return self }
    var outputs: FolderViewModelOutputs { return self }
    
    func fetchFolders(completion: (() -> Void)?) {
        myScallopManager.fetchMyFolderList(filter: folderFetchType.rawValue, completion: { result in
            switch result {
            case .success(let value):
                if let folders = value.result {
                    self.folders.value = folders
                    if let completionHandler = completion {
                        completionHandler()
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }

    func removeFolder(folderIndex index: Int, completionHandler: @escaping ((Result<FolderResponse, Error>) -> Void)) {
        myScallopManager.deleteFolder(folder: index, completion: completionHandler)
    }
    
    func fetchFolderDetail(folderIndex index: Int, completionHandler: @escaping (Result<FolderDetail, Error>) -> Void) {
        surfingManager.fetchFolderDetail(folder: index, completion: completionHandler)
    }
}
