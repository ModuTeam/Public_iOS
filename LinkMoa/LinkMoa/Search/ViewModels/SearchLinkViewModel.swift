//
//  SearchLinkViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/10.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchLinkViewModel: ViewModelType {
  
    struct Input {
        let searchInput: Signal<(word: String, page: Int, isMine: Int)>
        let resetInput: Signal<Void>
    }
    
    struct Output {
        var result: Driver<[SearchLink.Result]>
        var count: Driver<Int>
        var errorMessage: Signal<String>
    }
    
    private let networkManager = RxSurfingManager()
    private let disposeBag = DisposeBag()
    private let errorMessage: PublishRelay<String> = PublishRelay()
   
    func transform(input: Input) -> Output {
        let results = BehaviorRelay(value: [SearchLink.Result]())
        let count = BehaviorRelay(value: 0)
        
        input.searchInput
            .flatMap { self.searchLink(word: $0.0, page: $0.1, isMine: $0.2) }
            .drive {
                results.accept(results.value + $0.0)
                count.accept($0.1)
            }
            .disposed(by: disposeBag)
        
        input.resetInput
            .emit(onNext: { results.accept([]) })
            .disposed(by: disposeBag)
        
        return Output(result: results.asDriver(), count: count.asDriver(), errorMessage: errorMessage.asSignal())
    }
        
    func searchLink(word: String, page: Int, isMine: Int) -> Driver<([SearchLink.Result], Int)> {
        let params: [String: Any] = ["word": word,
                                     "page": page,
                                     "limit": Constant.pageLimit,
                                     "isMyFolders": isMine]
        
        return self.networkManager.provider.rx.request(.searchLink(params: params))
            .map(SearchLink.self)
            .map { response in
                if let result = response.result {
                    return (result, response.resultCount)
                }
                self.errorMessage.accept(response.message)
                return ([], response.resultCount)
            }
            .asDriver(onErrorJustReturn: ([], 0))
    }

}
