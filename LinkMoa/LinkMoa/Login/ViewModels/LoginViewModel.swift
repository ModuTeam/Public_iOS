//
//  LoginViewModel.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/08.
//

import Foundation

protocol LoginViewModelOutputs {}

protocol LoginViewModelInputs {
    func appleLogin(authCode code: String, handler completionHandler: @escaping (Result<AppleLogin.Response, Error>) -> ())
    func googleLogin(accessToken token: String, handler completionHandler: @escaping (Result<GoogleLogin.Response, Error>) -> ())
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

final class LoginViewModel: LoginViewModelOutputs, LoginViewModelInputs, LoginViewModelType {
    
    private let loginManager: LoginManager = LoginManager()
    
    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }
    
    func appleLogin(authCode code: String, handler completionHandler: @escaping (Result<AppleLogin.Response, Error>) -> ()) {
        loginManager.appleLogin(authCode: code, completion: { result in
            completionHandler(result)
        })
    }
    
    func googleLogin(accessToken token: String, handler completionHandler: @escaping (Result<GoogleLogin.Response, Error>) -> ()) {
        loginManager.googleLogin(accessToken: token, completion: { result in
            completionHandler(result)
        })
    }
}
