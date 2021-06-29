//
//  TodayFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/23.
//

import Foundation

struct TodayFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let userIndex: Int
    let message: String
    let result: [Result]
    
    enum CodingKeys: String, CodingKey {
        case userIndex = "userIdx"
        case isSuccess, code, message, result
    }
    
    struct Result: Codable {
//        let userIndex, userCategoryIndex: Int
//        let categoryName: String
        let index: Int
        let name: String
        let linkCount: Int
//        let folderType: FolderType
//        let likeCount: Int
        let linkImageURL: String
//        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
//            case userIndex = "userIdx"
//            case userCategoryIndex = "userCategoryIdx"
//            case categoryName
            case index = "folderIdx"
            case name = "folderName"
            case linkCount = "folderLinkCount"
//            case folderType
//            case likeCount = "likeFolderCount"
            case linkImageURL = "linkImageUrl"
//            case updatedAt
        }
        init() {
            self.init(index: 0, name: "추천 링크달", linkCount: 0, linkImageURL: "-1")
        }
        
        init(index: Int, name: String, linkCount: Int, linkImageURL: String) {
            self.index = index
            self.name = name
            self.linkCount = linkCount
            self.linkImageURL = linkImageURL
        }
    }
}
