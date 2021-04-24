//
//  FolderSelectViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/10.
//

import Foundation


protocol FolderSelectViewModelOutputs {
    var folders: Observable<[FolderList.Result]> { get }
}

protocol FolderSelectViewModelInputs {
    func fetchFolders()
}

protocol FolderSelectViewModelType {

}

final class FolderSelectViewModel: FolderSelectViewModelOutputs, FolderSelectViewModelInputs, FolderSelectViewModelType {
    private let myScallopManager = MyScallopManager()

    var folders: Observable<[FolderList.Result]> = Observable([])
    
    var inputs: FolderSelectViewModelInputs { return self }
    var outputs: FolderSelectViewModelOutputs { return self }
    
    func fetchFolders() {
        myScallopManager.fetchMyFolderList(completion: { result in
            switch result {
            case .success(let value):
                if let folders = value.result {
                    self.folders.value = folders
                }
            case .failure(let error):
                print(error)
            default:
                break
            }
            
        })
    }
}
