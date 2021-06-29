//
//  NicknameViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/27.
//

import Foundation

protocol NicknameViewModelOutputs {}

protocol NicknameViewModelInputs {
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> Void)
}

protocol NicknameViewModelType {
    var inputs: NicknameViewModelInputs { get }
    var outputs: NicknameViewModelOutputs { get }
}

final class NicknameViewModel: NicknameViewModelOutputs, NicknameViewModelInputs, NicknameViewModelType {
    
    private let myScallopManager = MyScallopManager()

    var inputs: NicknameViewModelInputs { return self }
    var outputs: NicknameViewModelOutputs { return self }
    
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> Void) {
        myScallopManager.patchUserInformation(params: params, completion: completion)
    }
}
