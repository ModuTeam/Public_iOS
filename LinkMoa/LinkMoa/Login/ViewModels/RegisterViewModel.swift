//
//  RegisterViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/19.
//

import Foundation

protocol RegisterViewModelOutputs {}

protocol RegisterViewModelInputs {
    func patchUserInformation(params: [String : Any], completion: @escaping (Result<UserInformationResponse, Error>) -> ())
}

protocol RegisterViewModelType {
    var inputs: RegisterViewModelInputs { get }
    var outputs: RegisterViewModelOutputs { get }
}

final class RegisterViewModel: RegisterViewModelOutputs, RegisterViewModelInputs, RegisterViewModelType {

    private let myScallopManager = MyScallopManager()

    var inputs: RegisterViewModelInputs { return self }
    var outputs: RegisterViewModelOutputs { return self }
    
    func patchUserInformation(params: [String : Any], completion: @escaping (Result<UserInformationResponse, Error>) -> ()) {
        myScallopManager.patchUserInformation(params: params, completion: completion)
    }
}
