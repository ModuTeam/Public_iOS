//
//  SurfingAPI.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Moya

enum SurfingAPI {
    case folderDetail(index: Int)
    case like(index: Int)
    
    case topTenFolder
    case likedFolder(params: [String: Any])
    case usersFolder(index: Int, params: [String: Any])
    
    case category(index: Int, params: [String: Any])
    case categoryDetail(mainIndex: Int, subIndex: Int, params: [String: Any])
    
    
    case searchFolder(params: [String: Any])
    case searchLink(params: [String: Any])
    
    case report(params: [String: Any])
    case categories
    
    case userInfo
    case deleteAccount(index: Int)
    
    case todayFolder
    case myFolderList(index: Int, filter: Int)
}

extension SurfingAPI: TargetType {
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
        case .folderDetail(let index):
            return "/folders/\(index)"
        case .like(let index):
            return "/folders/\(index)/like"
        
        case .topTenFolder:
            return "/folders/top"
        case .likedFolder:
            return "/users/like"
            
        case .usersFolder(let index, _):
            return "/users/\(index)/folders"
        case .category(let index, _):
            return "/categories/\(index)/folders"
        case .categoryDetail(let main, let sub, _):
            return "/categories/\(main)/detailCategories/\(sub)/folders"
        
            
        case .searchFolder:
            return "/folders/search"
        case .searchLink:
            return "/links/search"
            
        case .report:
            return "/reports"
        case .categories:
            return "/categories"
            
        case .userInfo:
            return "/users"
        case .deleteAccount(let index):
            return "/users/\(index)/status"
            
        case .todayFolder:
            return "/folders/today"
        case .myFolderList:
            return "/users/folders"
        }
    }
    
    var method: Method {
        switch self {
        case .folderDetail, .topTenFolder, .likedFolder, .usersFolder, .category, .categoryDetail, .searchFolder, .searchLink, .categories, .userInfo, .todayFolder, .myFolderList:
            return .get
        case .like, .report:
            return .post
        case .deleteAccount:
            return .patch
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .folderDetail, .like, .topTenFolder, .categories, .userInfo, .deleteAccount, .todayFolder:
            return .requestPlain

        case  .likedFolder(let params), .usersFolder(_, let params), .category(_, let params), .categoryDetail(_, _, let params),.searchFolder(let params), .searchLink(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case  .report(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        
        //위젯때 임시로작성함.
        case .myFolderList(_, let filter):
            let param: [String : Any] = ["page" : "0", "limit" : "100", "filter" : filter]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        guard let jwtToken = TokenManager().jwtToken else { fatalError() }
        
        return ["Content-Type": "application/json",
                "x-access-token": jwtToken]
    }
}


