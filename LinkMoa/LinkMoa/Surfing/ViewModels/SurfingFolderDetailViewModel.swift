//
//  SurfingFolderDetailViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/05/14.
//

import Foundation
import RxSwift
import RxCocoa

final class SurfingFolderDetailViewModel: ViewModelType {
    
    struct Dependency {
        let userName: String
        let userID: Int
        let linkList: [FolderDetail.Link]
    }
    
    struct Input {
        let fetchFolderDetail: Signal<Int>
        let likeAction: Signal<Int>
        let reportAction: Signal<Int>
    }
    
    struct Output {
        var folderDetail: Driver<FolderDetail.Result>
        var likeResult: Driver<(status: Int, count: Int)>
        var reportResult: Driver<Bool>
        var errorMessage: Signal<String>
    }
    
    private let networkManager = RxSurfingManager()
    private let disposeBag = DisposeBag()
    private let errorMessage: PublishRelay<String> = PublishRelay()
    
    var dependency = Dependency(userName: "", userID: 0, linkList: [])
    
    func transform(input: Input) -> Output {
        let folderDetail = input.fetchFolderDetail
            .flatMap { [weak self] target -> Driver<FolderDetail.Result> in
                guard let self = self else { return Driver.just(FolderDetail.Result.init()) }
                return self.loadFolderInfo(folder: target)
            }
        
        let likeResult = input.likeAction
            .flatMap { [weak self] target -> Driver<(status: Int, count: Int)> in
                guard let self = self else { return Driver.just((0, 0)) }
                return self.likeFolder(folder: target) }
        
        let reportResult = input.reportAction
            .flatMap { [weak self] target -> Driver<Bool> in
                guard let self = self else { return Driver.just(false) }
                return self.reportFolder(folder: target) }
        
        return Output(folderDetail: folderDetail, likeResult: likeResult, reportResult: reportResult, errorMessage: errorMessage.asSignal())
    }
}

extension SurfingFolderDetailViewModel {
    private func fetchFolderDetail(folder: Int) -> Single<FolderDetail> {
        return self.networkManager.provider.rx.request(.surfingFolderDetail(index: folder))
            .map(FolderDetail.self)
    }

    private func loadFolderInfo(folder: Int) -> Driver<FolderDetail.Result> {
        return fetchFolderDetail(folder: folder)
            .map { [weak self] response -> FolderDetail.Result in
                guard let self = self else { return FolderDetail.Result() }
                if let result = response.result, response.isSuccess {
                    self.dependency = Dependency(userName: result.userNickname, userID: result.userIndex, linkList: result.linkList)
                    return result
                } else {
                    self.errorMessage.accept(response.message)
                    return FolderDetail.Result()
                }
            }
            .asDriver(onErrorJustReturn: FolderDetail.Result())
    }
  
    private func likeFolder(folder: Int) -> Driver<(status: Int, count: Int)> {
        let like = fetchFolderDetail(folder: folder)
            .compactMap { $0.result }
            .map {(status: $0.likeStatus, count: $0.likeCount)}
        
        return networkManager.provider.rx.request(.like(index: folder))
            .map(LinkResponse.self)
            .filter { $0.isSuccess }
            .flatMap { _ in like }
            .asDriver(onErrorJustReturn: (status: 0, count: 0))
    }
    
    private func reportFolder(folder: Int) -> Driver<Bool> {
        let params: [String: Any] = ["folderIdx": folder]
        
        return self.networkManager.provider.rx.request(.report(params: params))
            .map(ReportResponse.self)
            .map { [weak self] response in
                guard let self = self else { return false }
                if response.isSuccess {
                    return true
                } else {
                    self.errorMessage.accept(response.message)
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
    }
}
