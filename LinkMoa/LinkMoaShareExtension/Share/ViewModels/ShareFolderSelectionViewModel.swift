//
//  ShareFolderSelectionViewModel.swift
//  LinkMoaShareExtension
//
//  Created by won heo on 2021/02/26.
//

import Foundation

protocol ShareFolderSelectionViewModelOutputs {
    var folders: Observable<[FolderList.Result]> { get }
}

protocol ShareFolderSelectionViewModelInputs {
    func fetchFolders()
}

protocol ShareFolderSelectionViewModelType {
    var inputs: ShareFolderSelectionViewModelInputs { get }
    var outputs: ShareFolderSelectionViewModelOutputs { get }
}

final class ShareFolderSelectionViewModel: ShareFolderSelectionViewModelInputs, ShareFolderSelectionViewModelOutputs, ShareFolderSelectionViewModelType {
    
    private let myScallopManager = MyScallopManager()
    var folders: Observable<[FolderList.Result]> = Observable([])
    
    var inputs: ShareFolderSelectionViewModelInputs { return self }
    var outputs: ShareFolderSelectionViewModelOutputs { return self }
    
    func fetchFolders() {
        myScallopManager.fetchMyFolderList(completion: { result in
            switch result {
            case .success(let value):
                if let folders = value.result {
                    self.folders.value = folders
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
