//
//  CategoryDetailFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/17.
//

import Foundation

struct CategoryDetailFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: Result
    
    struct Result: Codable {
        let count: Int
        let list: [FolderList]
        
        enum CodingKeys: String, CodingKey {
            case count = "folderCount"
            case list = "folderList"
        }
    }

    struct FolderList: Codable {
        let index: Int
        let name: String
//        let detailCategoryIndex: Int
//        let detailCategoryName: String
        let type: FolderType
        let linkCount, likeCount: Int
        let linkImageURL: String
        let updatedAt: String
        let likeStatus: Int

        enum CodingKeys: String, CodingKey {
            case index = "folderIdx"
            case name = "folderName"
//            case detailCategoryIndex = "detailCategoryIdx"
//            case detailCategoryName = "detailcategoryName"
            case type = "folderType"
            case linkCount = "folderLinkCount"
            case likeCount = "likeFolderCount"
            case linkImageURL = "linkImageUrl"
            case updatedAt, likeStatus
        }
    }
    
    enum FolderType: String, Codable {
        case privateFolder = "private"
        case publicFolder = "public"
    }
}

