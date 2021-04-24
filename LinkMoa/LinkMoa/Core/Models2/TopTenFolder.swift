//
//  TopTen.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/10.
//

import Foundation

struct TopTenFolder: Codable {
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
        let folderIndex, userIndex, categoryIndex: Int
        let categoryName: String
        let detailCategoryIndex: Int
        let detailCategoryName, folderName, folderType: String
        let linkCount, likeCount: Int
        let linkImageURL: String?
        let likeStatus: Int

        enum CodingKeys: String, CodingKey {
            case folderIndex = "folderIdx"
            case userIndex = "userIdx"
            case categoryIndex = "categoryIdx"
            case detailCategoryIndex = "detailCategoryIdx"
            case categoryName, detailCategoryName, folderName, folderType
            case linkCount = "folderLinkCount"
            case likeCount = "likeFolderCount"
            case linkImageURL = "linkImageUrl"
            case likeStatus
        }
        
        init() {
            self.init(userIndex: 0, folderIndex: 0, categoryIndex: 0, folderName: "", folderType: "", likeCount: 0, linkCount: 0, linkImageURL: "", likeStatus: 0, categoryName: "", detailCategoryIndex: 0, detailCategoryName: "")
        }
        
        init(userIndex: Int, folderIndex: Int, categoryIndex: Int, folderName: String, folderType: String, likeCount: Int, linkCount: Int, linkImageURL: String, likeStatus: Int, categoryName: String, detailCategoryIndex: Int, detailCategoryName: String) {
            
            self.folderIndex = folderIndex
            self.userIndex = userIndex
            self.categoryIndex = categoryIndex
            self.categoryName = categoryName
            self.detailCategoryIndex = detailCategoryIndex
            self.detailCategoryName = detailCategoryName
            self.folderName = folderName
            self.folderType = folderType
            self.likeCount = likeCount
            self.linkCount = linkCount
            self.linkImageURL = linkImageURL
            self.likeStatus = likeStatus
        }
    }
}
