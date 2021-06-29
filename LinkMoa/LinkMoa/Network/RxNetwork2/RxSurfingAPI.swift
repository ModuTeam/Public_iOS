//  RxSurfingAPI.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/05/13.
//

import Moya

enum RxSurfingAPI {
    // MARK: - folder
    case folderDetail(index: Int)
    case myFolderList(index: Int, filter: Int)
    case addFolder(params: [String: Any])
    case editFolder(index: Int, params: [String: Any])
    case deleteFolder(index: Int)
    case addLink(index: Int, params: [String: Any])
    case editLink(index: Int, params: [String: Any])
    case deleteLink(index: Int)
    case userInformation(params: [String: Any])
    
    // MARK: - surfing
    case surfingFolderDetail(index: Int)
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
}

extension RxSurfingAPI: TargetType {
    var baseURL: URL {
        switch Constant.serviceType {
        case .dev:
            guard let url = URL(string: PrivateKey.devServerDomatinURL) else { fatalError() }
            return url
        case .product:
            guard let url = URL(string: PrivateKey.productServerDomainURL) else { fatalError() }
            return url
        }
    }

    var path: String {
        switch self {
        // MARK: - folder
        case .folderDetail(let index):
            return "/folders/\(index)"
        case .myFolderList:
            return "/users/folders"
        case .addFolder:
            return "/folders"
        case .editFolder(let index, _):
            return "/folders/\(index)"
        case .deleteFolder(let index):
            return "/folders/\(index)/status"
            
        case .addLink(let index, _):
            return "/folders/\(index)/link"
        case .editLink(let index, _):
            return "/links/\(index)"
        case .deleteLink(let index):
            return "/links/\(index)/status"
        case .userInformation:
            return "/users"
            
        // MARK: - surfing
        case .surfingFolderDetail(let index):
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
        }
    }
    
    var method: Method {
        switch self {
        // MARK: - folder
        case .myFolderList, .folderDetail:
            return .get
        case .addFolder, .addLink:
            return .post
        case .editFolder, .editLink, .deleteFolder, .deleteLink, .userInformation:
            return .patch
            
        // MARK: - surfing
        case .surfingFolderDetail, .topTenFolder, .likedFolder, .usersFolder, .category, .categoryDetail, .searchFolder, .searchLink, .categories, .userInfo, .todayFolder:
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
        // MARK: - folder
        case .deleteFolder, .deleteLink:
            return .requestPlain
        case .folderDetail:
            let param = ["page": "0", "limit": "200"]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .myFolderList(_, let filter):
            let param: [String: Any] = ["page": "0", "limit": "200", "filter": filter]
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
        case .addFolder(let params),
             .editFolder(_, let params),
             .addLink(_, let params),
             .editLink(_, let params),
             .userInformation(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        
        // MARK: - surfing
        case .surfingFolderDetail, .like, .topTenFolder, .categories, .userInfo, .deleteAccount, .todayFolder:
            return .requestPlain

        case  .likedFolder(let params), .usersFolder(_, let params), .category(_, let params), .categoryDetail(_, _, let params), .searchFolder(let params), .searchLink(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case  .report(params: let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        guard let jwtToken = TokenManager().jwtToken else { fatalError() }

        return ["Content-Type": "application/json",
                "x-access-token": jwtToken]
    }
}
