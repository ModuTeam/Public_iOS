//
//  SurfingFolderViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/05/27.
//

import Foundation
import RxSwift
import RxCocoa

final class SurfingFolderViewModel: ViewModelType {
    
    struct Input {
        let fetchTopTenFolder: Signal<Void>
        let fetchLikedFolders: Signal<(word: String?, page: Int)>
        let fetchUsersFolders: Signal<(user: Int, page: Int)>
    }
    
    struct Output {
        var folders: Driver<[IntegratedFolder]>
        var errorMessage: Signal<String>
    }
    
    private let networkManager = RxSurfingManager()
    private let disposeBag = DisposeBag()
    private let errorMessage: PublishRelay<String> = PublishRelay()
    
    func transform(input: Input) -> Output {
        let folders: BehaviorRelay<[IntegratedFolder]> = .init(value: [])
        
        input.fetchTopTenFolder
            .flatMap { [weak self] _ -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                DEBUG_LOG(Thread.isMainThread)
                return self.fetchTopTenFolder()
            }
            .drive { folders.accept($0) }
            .disposed(by: disposeBag)
        
        input.fetchLikedFolders
            .flatMap { [weak self] target -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                return self.fetchLikedFolders(word: target.word, page: target.page)
            }
            .drive { folders.accept($0) }
            .disposed(by: disposeBag)
        
        input.fetchUsersFolders
            .flatMap { [weak self] target -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                DEBUG_LOG(Thread.isMainThread)
                return self.fetchUsersFolders(user: target.user, page: target.page)
            }
            .drive { folders.accept($0) }
            .disposed(by: disposeBag)
        
        return Output(folders: folders.asDriver(), errorMessage: errorMessage.asSignal())
    }
}

extension SurfingFolderViewModel {
    private func fetchTopTenFolder() -> Driver<[IntegratedFolder]> {
        return self.networkManager.provider.rx.request(.topTenFolder)
            .map(TopTenFolder.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                DEBUG_LOG(Thread.isMainThread)
                if response.isSuccess {
                    return response.result
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    private func fetchLikedFolders(word: String?, page: Int) -> Driver<[IntegratedFolder]> {
        var params: [String: Any] = ["page": page, "limit": 200]
        
        // 찜한 링크달 검색을 위해 만들어 놓았으나 아직 사용안함.
        if let word = word {
            params["word"] = word
        }
        return self.networkManager.provider.rx.request(.likedFolder(params: params))
            .map(LikedFolder.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                if let result = response.result, response.isSuccess {
                    return result
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    private func fetchUsersFolders(user: Int, page: Int) -> Driver<[IntegratedFolder]> {
        let params: [String: Any] = ["page": page, "limit": 100]
        
        return self.networkManager.provider.rx.request(.usersFolder(index: user, params: params))
            .map(UsersFolder.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                if response.isSuccess {
                    return response.result
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
}
