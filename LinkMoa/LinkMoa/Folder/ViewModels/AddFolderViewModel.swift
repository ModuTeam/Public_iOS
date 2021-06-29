//
//  AddFolderViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/09.
//

import Foundation

protocol AddFolderViewModelOutputs {}

protocol AddFolderViewModelInputs {
    func addFolder(folderParam param: [String: Any], completionHandler: @escaping ((Result<NewFolder, Error>) -> Void))
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> Void)
}

protocol AddFolderViewModelType {
    var inputs: AddFolderViewModelInputs { get }
    var outputs: AddFolderViewModelOutputs { get }
}

final class AddFolderViewModel: AddFolderViewModelType, AddFolderViewModelOutputs, AddFolderViewModelInputs {
    
    private let myScallopManager = MyScallopManager()
    
    var inputs: AddFolderViewModelInputs { return self }
    var outputs: AddFolderViewModelOutputs { return self }

    func addFolder(folderParam param: [String: Any], completionHandler: @escaping (Result<NewFolder, Error>) -> Void) {
        myScallopManager.addNewFolder(params: param, completion: completionHandler)
    }
    
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        myScallopManager.editFolder(folder: index, params: params, completion: completion)
    }
}
