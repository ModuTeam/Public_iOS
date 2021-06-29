//
//  CategoryViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/05/28.
//

import Foundation
import RxSwift
import RxCocoa

final class CategoryFolderViewModel: ViewModelType {
    
    struct Input {
        let fetchFolder: Signal<(main: Int, sub: Int, last: Int)>
        let resetFolder: Signal<Void>
        let fetchCategory: Signal<Int>
    }
    
    struct Output {
        var categoryDetailFolders: Driver<[IntegratedFolder]>
        var categories: Driver<[CategoryInfo.DetailCategoryList]>
        var errorMessage: Signal<String>
    }
    
    private let networkManager = RxSurfingManager()
    private let disposeBag = DisposeBag()
    private let errorMessage: PublishRelay<String> = PublishRelay()

    func transform(input: Input) -> Output {
        let folders: BehaviorRelay<[IntegratedFolder]> = .init(value: [])
        
        input.fetchFolder
            .flatMap { [weak self] target -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                return self.fetchCategoryDetailFolder(mainIndex: target.main, subIndex: target.sub, lastFolder: target.last)
            }
            .drive { folders.accept(folders.value + $0) }
            .disposed(by: disposeBag)
        
        input.resetFolder
            .emit(onNext: { folders.accept([]) })
            .disposed(by: disposeBag)
        
        let categories = input.fetchCategory
            .flatMap {  [weak self] target -> Driver<[CategoryInfo.DetailCategoryList]> in
                guard let self = self else { return Driver.just([]) }
                return self.fetchCategories(index: target)
            }
        
        return Output(categoryDetailFolders: folders.asDriver(), categories: categories, errorMessage: errorMessage.asSignal())
    }
}

extension CategoryFolderViewModel { 
    private func fetchCategoryDetailFolder(mainIndex: Int, subIndex: Int, lastFolder: Int) -> Driver<[IntegratedFolder]> {
        let params: [String: Any] = ["limit": Constant.pageLimit, "lastFolderIdx": lastFolder]
        DEBUG_LOG("mainIndex: \(mainIndex), subIndex: \(subIndex), lastFolder: \(lastFolder)")
        
         return self.networkManager.provider.rx.request(.categoryDetail(mainIndex: mainIndex + 1, subIndex: subIndex, params: params))
            .map(CategoryDetailFolder.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                if response.isSuccess {
                    return response.result.list
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    private func fetchCategories(index: Int) -> Driver<[CategoryInfo.DetailCategoryList]> {
        return self.networkManager.provider.rx.request(.categories)
            .map(CategoryInfo.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                if response.isSuccess {
                    return [CategoryInfo.DetailCategoryList(detailIndex: 0, detailName: "전체")] + response.result[index].detailList
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}
