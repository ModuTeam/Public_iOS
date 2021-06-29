//
//  MyScallopManager.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation
import Moya

protocol MyScallopNetworkable {
    var provider: MoyaProvider<MyScallopAPI> { get }

    func fetchMyFolderList(filter: Int, completion: @escaping (Result<FolderList, Error>) -> Void)
    
    func addNewFolder(params: [String: Any], completion: @escaping (Result<NewFolder, Error>) -> Void)
    
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> Void)
    
    func deleteFolder(folder index: Int, completion: @escaping (Result<FolderResponse, Error>) -> Void)
    
    func addLink(folder index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> Void)
    
    func editLink(link index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> Void)
    
    func deleteLInk(link index: Int, completion: @escaping (Result<LinkResponse, Error>) -> Void)
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> Void)
    
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> Void)
}

struct MyScallopManager: MyScallopNetworkable {
    //    var provider: MoyaProvider<MyScallopAPI> = MoyaProvider<MyScallopAPI>(plugins: [NetworkLoggerPlugin()])
    var provider: MoyaProvider<MyScallopAPI> = MoyaProvider<MyScallopAPI>(plugins: [])
    
    func deleteLInk(link index: Int, completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        request(target: .deleteLink(index: index), completion: completion)
    }
    
    func addLink(folder index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        request(target: .addLink(index: index, params: params), completion: completion)
    }
    
    func editLink(link index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        request(target: .editLink(index: index, params: params), completion: completion)
    }
    
    func deleteFolder(folder index: Int, completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        request(target: .deleteFolder(index: index), completion: completion)
    }
    
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        request(target: .editFolder(index: index, params: params), completion: completion)
    }
  
    func addNewFolder(params: [String: Any], completion: @escaping (Result<NewFolder, Error>) -> Void) {
        request(target: .addFolder(params: params), completion: completion)
    }

    func fetchMyFolderList(filter: Int = 1, completion: @escaping (Result<FolderList, Error>) -> Void) { // user index: Int,
        guard let userIndex = TokenManager().userIndex else { fatalError() }
        
        request(target: .myFolderList(index: userIndex, filter: filter), completion: completion)
    }
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> Void) {
        request(target: .folderDetail(index: index), completion: completion)
    }
    
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> Void) {
        request(target: .userInformation(params: params), completion: completion)
    }
}

private extension MyScallopManager {
    private func request<T: Decodable>(target: MyScallopAPI, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
//                    print(String(data: response.data, encoding: .utf8) ?? "")
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    // for test
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
