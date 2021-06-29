//
//  RxMyPageViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    // MARK: - Input & Output
    struct Input {
        let fetchUserNickname: Observable<Void>
        let useSafariToggle: Observable<Bool>
        let changeUserNickName: Observable<String>
        let logout: Observable<Void>
        let deleteUser: Observable<Void>
    }
    
    struct Output {
        let bottomAlert: Driver<Void>
        let error: Driver<String>
        let userNickName: Driver<String>
        let settingMenus: Driver<[String]>
        let isUseSafari: Driver<Bool>
    }
    
    // MARK: - Token User Defaults
    private var tokenManaer = TokenManager()
    
    // MARK: - Network
    private let surfingManager = SurfingManager()
    private let myScallopManager = MyScallopManager()
    private let myPageService: MyPageService = MyPageService()
    private let disposeBag = DisposeBag()
    
    // MARK: - Output Relays
    private let bottomAlert: PublishRelay<Void> = PublishRelay()
    private let error: PublishRelay<String> = PublishRelay()
    private let userNickName: BehaviorRelay<String> = BehaviorRelay(value: "")
    private let settingMenus: BehaviorRelay<[String]> = BehaviorRelay(value: ["FAQ", "건의&불편신고", "링크모아 브라우저 사용하기", "버전 정보", "오픈소스 라이센스 이용고지", "탈퇴하기"])
    private let isUseSafari: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    // MARK: - Public Variables
    public var nickName: String {
        return self.userNickName.value
    }
    
    public var id: Int = 0
    
    func transform(input: Input) -> Output {
        let succeedChangeNickname = PublishSubject<Void>()
        
        Observable.merge([input.fetchUserNickname, succeedChangeNickname.asObservable()])
        .flatMap { self.myPageService.getUserInfo() }
            .subscribe(onNext: { result in
                switch result {
                case .success(let userInfo):
                    self.id = userInfo.index
                    self.userNickName.accept(userInfo.nickname)
                case .error(let myPageError):
                    self.error.accept(myPageError.message)
                }
            })
        .disposed(by: disposeBag)
        
        input.useSafariToggle
            .bind(onNext: { isUsingCustomBrowser in
                self.tokenManaer.isUsingCustomBrowser = isUsingCustomBrowser
            })
            .disposed(by: disposeBag)
        
        input.logout
            .subscribe(onNext: {
                self.tokenManaer.jwtToken = nil
            })
            .disposed(by: disposeBag)
        
        input.changeUserNickName.flatMap { self.myPageService.requestChangeNickname(nickName: $0) }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    succeedChangeNickname.onNext(())
                    self.bottomAlert.accept(())
                case .error(let myPageError):
                    self.error.accept(myPageError.message)
                }
            })
            .disposed(by: disposeBag)
        
        input.deleteUser.flatMap { self.myPageService.deleteUser(id: self.id) }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    self.tokenManaer.jwtToken = nil
                case .error(let myPageError):
                    self.error.accept(myPageError.message)
                }
            })
            .disposed(by: disposeBag)
        
        // 초기값 설정
        isUseSafari.accept(tokenManaer.isUsingCustomBrowser ?? false)
        
        return Output(bottomAlert: bottomAlert.asDriver(onErrorJustReturn: ()), error: error.asDriver(onErrorJustReturn: ""), userNickName: userNickName.asDriver(), settingMenus: settingMenus.asDriver(), isUseSafari: isUseSafari.asDriver())
    }
}
