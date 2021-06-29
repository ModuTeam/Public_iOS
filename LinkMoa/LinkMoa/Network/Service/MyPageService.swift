//
//  MyPageService.swift
//  LinkMoa
//
//  Created by won heo on 2021/06/10.
//

import Foundation
import Moya
import RxSwift

enum MyPageError: Int, Error {
    case server = 2000
    case resignUser = 2010
    case network = -1
    
    var message: String {
        switch self {
        case .network:
            return "네트워크 에러가 발생했습니다."
        case .server:
            return "서버 에러가 발생했습니다."
        case .resignUser:
            return "탈퇴한 회원입니다."
        }
    }
}

enum MyPageResult<T> {
    case success(T)
    case error(MyPageError)
}

class MyPageService {
    let rxSurfingProvider: MoyaProvider<RxSurfingAPI> = MoyaProvider<RxSurfingAPI>()
    let myScallopProvider: MoyaProvider<MyScallopAPI> = MoyaProvider<MyScallopAPI>()
    let disposeBag: DisposeBag = DisposeBag()
    
    func getUserInfo() -> Observable<MyPageResult<UserInfo.Result>> {
        return Observable.create({ observer in
            self.rxSurfingProvider.rx.request(.userInfo)
                .map(UserInfo.self)
                .subscribe(onSuccess: { userInfo in
                    if userInfo.isSuccess == false {
                        var error: MyPageError = .server
                        
                        switch userInfo.code {
                        case MyPageError.network.rawValue:
                            error = .network
                        case MyPageError.resignUser.rawValue:
                            error = .resignUser
                        default:
                            break
                        }
                        
                        observer.onNext(.error(error))
                        return
                    }
                    
                    if let user = userInfo.result.first {
                        observer.onNext(.success(user))
                    }
                }, onError: { _ in
                    observer.onError(MyPageError.network)
                })
                .disposed(by: self.disposeBag)

            return Disposables.create()
        })
    }
    
    func requestChangeNickname(nickName: String) -> Observable<MyPageResult<String>> {
        return Observable.create({ observer in
            self.myScallopProvider.rx.request(.userInformation(params: ["userNickname": nickName]))
                .map(FolderResponse.self)
                .subscribe(onSuccess: { result in
                    if result.isSuccess == false {
                        var error: MyPageError = .server
                        
                        switch result.code {
                        case MyPageError.network.rawValue:
                            error = .network
                        case MyPageError.resignUser.rawValue:
                            error = .resignUser
                        default:
                            break
                        }
                        
                        observer.onNext(.error(error))
                        return
                    }
                    
                    observer.onNext(.success("닉네임 변경 성공"))
                }, onError: { _ in
                    observer.onError(MyPageError.network)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
    
    func deleteUser(id: Int) -> Observable<MyPageResult<String>> {
        return Observable.create({ observer in
            self.rxSurfingProvider.rx.request(.deleteAccount(index: id))
                .map(FolderResponse.self)
                .subscribe(onSuccess: { result in
                    if result.isSuccess == false {
                        var error: MyPageError = .server
                        
                        switch result.code {
                        case MyPageError.network.rawValue:
                            error = .network
                        case MyPageError.resignUser.rawValue:
                            error = .resignUser
                        default:
                            break
                        }
                        
                        observer.onNext(.error(error))
                        return
                    }
                    
                    observer.onNext(.success("유저 계정 삭제 성공"))
                }, onError: { _ in
                    observer.onError(MyPageError.network)
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        })
    }
}
