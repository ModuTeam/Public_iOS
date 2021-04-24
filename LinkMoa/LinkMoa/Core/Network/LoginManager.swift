//
//  LoginManager.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/08.
//

import Foundation
import Moya

protocol LoginNetworkable {
    var provider: MoyaProvider<LoginAPI> { get }

    func appleLogin(authCode code: String, completion: @escaping (Result<AppleLogin.Response, Error>) -> ())
    func googleLogin(accessToken token: String, completion: @escaping (Result<GoogleLogin.Response, Error>) -> ())
}

struct LoginManager: LoginNetworkable {
//    var provider: MoyaProvider<LoginAPI> = MoyaProvider<LoginAPI>(plugins: [NetworkLoggerPlugin()])
    
    var provider: MoyaProvider<LoginAPI> = MoyaProvider<LoginAPI>(plugins: [])
    
    func appleLogin(authCode code: String, completion: @escaping (Result<AppleLogin.Response, Error>) -> ()) {
        request(target: .appleLogin(authCode: code), completion: completion)
    }
    
    func googleLogin(accessToken token: String, completion: @escaping (Result<GoogleLogin.Response, Error>) -> ()) {
        request(target: .googleLogin(accessToken: token), completion: completion)
    }
}

private extension LoginManager {
    private func request<T: Decodable>(target: LoginAPI, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    // print(String(data: response.data, encoding: .utf8))
                    
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
