//
//  SurfingManager.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation
import Moya

protocol SurfingNetworkable {
    var provider: MoyaProvider<SurfingAPI> { get }
    
    func fetchTopTenFolder(completion: @escaping (Result<TopTenFolder, Error>) -> Void)
    
    func fetchLikedFolders(params: [String: Any], completion: @escaping (Result<LikedFolder, Error>) -> Void)
    
    func fetchUsersFolders(folder index: Int, params: [String: Any], completion: @escaping (Result<UsersFolder, Error>) -> Void)
    
    func fetchCategoryFolders(folder index: Int, params: [String: Any], completion: @escaping (Result<CategoryFolder, Error>) -> Void)
    
    func fetchCategoryDetailFolders(folder mainIndex: Int, detail subIndex: Int, params: [String: Any], completion: @escaping (Result<CategoryDetailFolder, Error>) -> Void)
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> Void)
    
    func likeFolder(folder index: Int, completion: @escaping (Result<LinkResponse, Error>) -> Void)
    
    func searchFolder(params: [String: Any], completion: @escaping (Result<SearchFolder, Error>) -> Void)

    func searchLink(params: [String: Any], completion: @escaping (Result<SearchLink, Error>) -> Void)
    
    func reportFolder(params: [String: Any], completion: @escaping (Result<ReportResponse, Error>) -> Void)
    
    func fetchCategories(completion: @escaping (Result<CategoryInfo, Error>) -> Void)
    
    func fetchUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void)
    
    func deleteAccount(user index: Int, completion: @escaping (Result<FolderResponse, Error>) -> Void)
    
    func fetchTodayFolder(completion: @escaping (Result<TodayFolder, Error>) -> Void)
    
    func fetchMyFolderList(filter: Int, completion: @escaping (Result<FolderList, Error>) -> Void) // user index: Int,
}

struct SurfingManager: SurfingNetworkable {
//         var provider: MoyaProvider<SurfingAPI> = MoyaProvider<SurfingAPI>(plugins: [NetworkLoggerPlugin()])
    var provider: MoyaProvider<SurfingAPI> = MoyaProvider<SurfingAPI>(plugins: [])
    
    func fetchTopTenFolder(completion: @escaping (Result<TopTenFolder, Error>) -> Void) {
        request(target: .topTenFolder, completion: completion)
    }
    
    func fetchLikedFolders(params: [String: Any], completion: @escaping (Result<LikedFolder, Error>) -> Void) {
        request(target: .likedFolder(params: params), completion: completion)
    }
    
    func fetchUsersFolders(folder index: Int, params: [String: Any], completion: @escaping (Result<UsersFolder, Error>) -> Void) {
        request(target: .usersFolder(index: index, params: params), completion: completion)
    }
    
    func fetchCategoryFolders(folder index: Int, params: [String: Any], completion: @escaping (Result<CategoryFolder, Error>) -> Void) {
        request(target: .category(index: index, params: params), completion: completion)
    }
    
    func fetchCategoryDetailFolders(folder mainIndex: Int, detail subIndex: Int, params: [String: Any], completion: @escaping (Result<CategoryDetailFolder, Error>) -> Void) {
        request(target: .categoryDetail(mainIndex: mainIndex, subIndex: subIndex, params: params), completion: completion)
    }
    
    func fetchFolderDetail(folder index: Int, completion: @escaping (Result<FolderDetail, Error>) -> Void) {
        request(target: .folderDetail(index: index), completion: completion)
    }
    
    func likeFolder(folder index: Int, completion: @escaping (Result<LinkResponse, Error>) -> Void) {
        request(target: .like(index: index), completion: completion)
    }

    func searchFolder(params: [String: Any], completion: @escaping (Result<SearchFolder, Error>) -> Void) {
        request(target: .searchFolder(params: params), completion: completion)
    }

    func searchLink(params: [String: Any], completion: @escaping (Result<SearchLink, Error>) -> Void) {
        request(target: .searchLink(params: params), completion: completion)
    }
    
    func reportFolder(params: [String: Any], completion: @escaping (Result<ReportResponse, Error>) -> Void) {
        request(target: .report(params: params), completion: completion)
    }
    
    func fetchCategories(completion: @escaping (Result<CategoryInfo, Error>) -> Void) {
        request(target: .categories, completion: completion)
    }
    
    func fetchUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        request(target: .userInfo, completion: completion)
    }
    
    func deleteAccount(user index: Int, completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        request(target: .deleteAccount(index: index), completion: completion)
    }
    
    func fetchTodayFolder(completion: @escaping (Result<TodayFolder, Error>) -> Void) {
        request(target: .todayFolder, completion: completion)
    }
    
    func fetchMyFolderList(filter: Int = 1, completion: @escaping (Result<FolderList, Error>) -> Void) { // user index: Int,
        guard let userIndex = TokenManager().userIndex else { fatalError() }
        
        request(target: .myFolderList(index: userIndex, filter: filter), completion: completion)
    }
    
}

private extension SurfingManager {
    private func request<T: Decodable>(target: SurfingAPI, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    // DEBUG_LOG(String(data: response.data, encoding: .utf8))
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
