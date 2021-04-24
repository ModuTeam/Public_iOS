//
//  UsersFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/29.
//

import Foundation

struct UsersFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [Result]

    struct Result: Codable {
        let index: Int
        let name: String
        let categoryIdx: Int
        let categoryName: String
        let detailCategoryIdx: Int
        let detailCategoryName: String
        let type: FolderType
        let linkCount, likeCount: Int
        let linkImageURL: String
        let updatedAt: String
        let likeStatus: Int

        enum CodingKeys: String, CodingKey {
            case index = "folderIdx"
            case name = "folderName"
            case categoryIdx, categoryName, detailCategoryIdx, detailCategoryName
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
