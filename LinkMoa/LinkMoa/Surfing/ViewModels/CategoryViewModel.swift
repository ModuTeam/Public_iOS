//
//  CategoryViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/11.
//

import Foundation

protocol CategoryViewModelOutputs {
    var categoryFolders: Observable<[CategoryFolder.FolderList]> { get }
    var categoryDetailFolders: Observable<[CategoryDetailFolder.FolderList]> { get }
    var categories: Observable<[CategoryInfo.DetailCategoryList]> { get }
}

protocol CategoryViewModelInputs {
//    func fetchCategoryFolder(index: Int, page: Int, lastFolder: Int)
    func fetchCategoryDetailFolder(mainIndex: Int, subIndex: Int, lastFolder: Int, completion: (() -> Void)?)
    func fetchCategories(at index: Int)
}

protocol CategoryViewModelType {
    var inputs: CategoryViewModelInputs { get }
    var outputs: CategoryViewModelOutputs { get }
}

final class CategoryViewModel: CategoryViewModelOutputs, CategoryViewModelInputs, CategoryViewModelType {
    
    init() {
        self.surfingManager = SurfingManager()
    }
    
    private let surfingManager: SurfingManager
    
    var inputs: CategoryViewModelInputs { return self }
    var outputs: CategoryViewModelOutputs { return self }
    
    var categoryFolders: Observable<[CategoryFolder.FolderList]> = Observable([])
    var categoryDetailFolders: Observable<[CategoryDetailFolder.FolderList]> = Observable([])
    var categories: Observable<[CategoryInfo.DetailCategoryList]> = Observable([])
    
    func fetchCategoryDetailFolder(mainIndex: Int, subIndex: Int, lastFolder: Int, completion: (() -> Void)?) {
        let params: [String: Any] = ["limit": Constant.pageLimit,
                                     "lastFolderIdx": lastFolder
        ]
      
        surfingManager.fetchCategoryDetailFolders(folder: mainIndex, detail: subIndex, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
                
            case .success(let response):
                let data = response.result.list
                self.categoryDetailFolders.value = data
                if let completionHandler = completion {
                    completionHandler()
                }
            }
        }
    }
    
    func fetchCategories(at index: Int) {
        surfingManager.fetchCategories() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
//                DEBUG_LOG(response.result)
                var list: [CategoryInfo.DetailCategoryList] = [CategoryInfo.DetailCategoryList(detailIndex: 0, detailName: "전체")]
                list.append(contentsOf: response.result[index].detailList)
                self.categories.value = list
            }
        }
    }
}
