//
//  MyPageViewModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/17.
//

import Foundation

protocol MyPageViewModelOutputs {
    var userInfo: Observable<[UserInfo.Result]> { get }
    
}

protocol MyPageViewModelInputs {
    func fetchUserInfo()
    func deleteAccount(index: Int, completionHandler: (() -> Void)?)
}

protocol MyPageViewModelType {
    var inputs: MyPageViewModelInputs { get }
    var outputs: MyPageViewModelOutputs { get }
}

final class MyPageViewModel: MyPageViewModelOutputs, MyPageViewModelInputs, MyPageViewModelType {
    
    init() {
        self.surfingManager = SurfingManager()
    }
    
    private let surfingManager: SurfingManager
    
    var inputs: MyPageViewModelInputs { return self }
    var outputs: MyPageViewModelOutputs { return self }
    
    var userInfo: Observable<[UserInfo.Result]> = Observable([])
    
    func fetchUserInfo() {
        surfingManager.fetchUserInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
//                DEBUG_LOG(response.result)
                self.userInfo.value = response.result
            }
        }
    }
    
    func deleteAccount(index: Int, completionHandler: (() -> Void)?) {
        surfingManager.deleteAccount(user: index) { result in
            switch result {
            case .failure(let error):
                DEBUG_LOG(error)
            case .success(let response):
                DEBUG_LOG(response.message)
                completionHandler?()
            }
        }
        
    }
}
