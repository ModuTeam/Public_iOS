//
//  LoginApi.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/08.
//

import Moya

enum LoginAPI {
    case appleLogin(authCode: String)
    case googleLogin(accessToken: String)
}

extension LoginAPI: TargetType {
    var baseURL: URL {
        switch Constant.serviceType {
        case .dev:
            guard let url = URL(string: PrivateKey.productServerDomainURL) else { fatalError() }
            return url
        case .product:
            guard let url = URL(string: PrivateKey.devServerDomatinURL) else { fatalError() }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .appleLogin:
            return "/apple-login"
        case .googleLogin:
            return "/google-login"
        }
    }
    
    var method: Method {
        switch self {
        case .appleLogin:
            return .post
        case .googleLogin:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .appleLogin(let authCode):
            return .requestParameters(parameters: ["code": authCode], encoding: JSONEncoding.default)
        case .googleLogin(let accessToken):
            return .requestParameters(parameters: ["access_token": accessToken], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

