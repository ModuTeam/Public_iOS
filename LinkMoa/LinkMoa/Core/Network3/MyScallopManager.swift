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

    func fetchMyFolderList(filter: Int, completion: @escaping (Result<FolderList, Error>) -> ())
    
    func addNewFolder(params: [String: Any], completion: @escaping (Result<NewFolder, Error>) -> ())
    
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> ())
    
    func deleteFolder(folder index: Int, completion: @escaping (Result<FolderResponse, Error>) -> ())
    
    func addLink(folder index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> ())
    
    func editLink(link index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> ())
    
    func deleteLInk(link index: Int, completion: @escaping (Result<LinkResponse, Error>) -> ())
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> ())
    
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> ())
}

struct MyScallopManager: MyScallopNetworkable {
    //    var provider: MoyaProvider<MyScallopAPI> = MoyaProvider<MyScallopAPI>(plugins: [NetworkLoggerPlugin()])
    var provider: MoyaProvider<MyScallopAPI> = MoyaProvider<MyScallopAPI>(plugins: [])
    
    func deleteLInk(link index: Int, completion: @escaping (Result<LinkResponse, Error>) -> ()) {
        request(target: .deleteLink(index: index), completion: completion)
    }
    
    func addLink(folder index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> ()) {
        request(target: .addLink(index: index, params: params), completion: completion)
    }
    
    func editLink(link index: Int, params: [String: Any], completion: @escaping (Result<LinkResponse, Error>) -> ()) {
        request(target: .editLink(index: index, params: params), completion: completion)
    }
    
    func deleteFolder(folder index: Int, completion: @escaping (Result<FolderResponse, Error>) -> ()) {
        request(target: .deleteFolder(index: index), completion: completion)
    }
    
    func editFolder(folder index: Int, params: [String: Any], completion: @escaping (Result<FolderResponse, Error>) -> ()) {
        request(target: .editFolder(index: index, params: params), completion: completion)
    }
  
    func addNewFolder(params: [String: Any], completion: @escaping (Result<NewFolder, Error>) -> ()) {
        request(target: .addFolder(params: params), completion: completion)
    }

    func fetchMyFolderList(filter: Int = 1, completion: @escaping (Result<FolderList, Error>) -> ()) { // user index: Int,
        guard let userIndex = TokenManager().userIndex else { fatalError() }
        
        request(target: .myFolderList(index: userIndex, filter: filter), completion: completion)
    }
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> ()) {
        request(target: .folderDetail(index: index), completion: completion)
    }
    
    func patchUserInformation(params: [String: Any], completion: @escaping (Result<UserInformationResponse, Error>) -> ()) {
        request(target: .userInformation(params: params), completion: completion)
    }
}

private extension MyScallopManager {
    private func request<T: Decodable>(target: MyScallopAPI, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    print(String(data: response.data, encoding: .utf8))

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
