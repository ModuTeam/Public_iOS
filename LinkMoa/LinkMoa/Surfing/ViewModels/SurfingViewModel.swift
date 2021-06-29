//
//  SurfingViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/08.
//

import Foundation
import RxSwift
import RxCocoa

final class SurfingViewModel: ViewModelType {

    struct Input {
        let fetchTopTenFolders: Signal<Void>
        let fetchLikedFolders: Signal<Void>
    }
    
    struct Output {
        var sections: Driver<[SurfingSectionModel]>
        var errorMessage: Signal<String>
    }
    
    private let networkManager = RxSurfingManager()
    private let disposeBag = DisposeBag()
    private let errorMessage: PublishRelay<String> = PublishRelay()
    
    func transform(input: Input) -> Output {
        let sections: BehaviorRelay<[SurfingSectionModel]> = BehaviorRelay(value: [
            .topTenSection(items: .init(repeating: .topTenItem(folder: .init()), count: 4)),
            .categorySection(items: Array(0...4).map {.categoryItem(index: $0)}),
            .likedSection(items: [])
        ])
        
        input.fetchTopTenFolders
            .flatMap { [weak self] _ -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                return self.fetchTopTenFolders()
            }
            .map { [SurfingSectionModel.topTenSection(items: $0.map { .topTenItem(folder: $0)})] }
            .drive { sections.accept($0 + sections.value[1...2]) }
            .disposed(by: disposeBag)
        
        input.fetchLikedFolders
            .flatMap { [weak self] _ -> Driver<[IntegratedFolder]> in
                guard let self = self else { return Driver.just([]) }
                return self.fetchLikedFolders()
            }
            .map { [SurfingSectionModel.likedSection(items: $0.map { .likedItem(folder: $0)})] }
            .drive { sections.accept(sections.value[0...1] + $0) }
            .disposed(by: disposeBag)

        return Output(sections: sections.asDriver(), errorMessage: errorMessage.asSignal())
    }
}

extension SurfingViewModel {
    private func fetchTopTenFolders() -> Driver<[IntegratedFolder]> {
        return self.networkManager.provider.rx.request(.topTenFolder)
            .map(TopTenFolder.self)
            .map { [weak self] response in
                guard let self = self else { return [] }
                if response.isSuccess {
                    return Array(response.result.prefix(4))
                } else {
                    self.errorMessage.accept(response.message)
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    private func fetchLikedFolders() -> Driver<[IntegratedFolder]> {
        let params: [String: Any] = ["page": 0, "limit": 4]
        
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
}
