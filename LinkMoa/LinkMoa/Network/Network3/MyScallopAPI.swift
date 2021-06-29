//
//  MyScallopAPI.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Moya

enum MyScallopAPI {
    case folderDetail(index: Int)
    case myFolderList(index: Int, filter: Int)
    case addFolder(params: [String: Any])
    case editFolder(index: Int, params: [String: Any])
    case deleteFolder(index: Int)
    case addLink(index: Int, params: [String: Any])
    case editLink(index: Int, params: [String: Any])
    case deleteLink(index: Int)
    case userInformation(params: [String: Any])
}

extension MyScallopAPI: TargetType {
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
        }
    }
    
    var method: Method {
        switch self {
        case .myFolderList, .folderDetail:
            return .get
        case .addFolder, .addLink:
            return .post
        case .editFolder, .editLink, .deleteFolder, .deleteLink, .userInformation:
            return .patch  
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
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
        }
    }
    
    var headers: [String: String]? {
        
        guard let jwtToken = TokenManager().jwtToken else {
            DEBUG_LOG("jwt 토큰이 존재하지 않습니다.")
            return nil
        }

        return ["Content-Type": "application/json",
                "x-access-token": jwtToken]
    }
}
