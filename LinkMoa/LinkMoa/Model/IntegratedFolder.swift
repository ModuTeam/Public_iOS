//
//  IntegratedFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/18.
//

import Foundation

struct IntegratedFolder: Codable {
    let categoryIndex: Int?
    let categoryName: String?
    let detailCategoryIndex: Int
    let detailCategoryName: String
    let folderIndex: Int
    let folderName: String
    let folderType: String
    let folderUpdatedAt: String?
    let likeCount: Int
    let likeStatus: Int
    let linkCount: Int
    let linkImageURL: String?
    let updatedAt: String?
    let userIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case categoryIndex = "categoryIdx"
        case categoryName
        case detailCategoryIndex = "detailCategoryIdx"
        case detailCategoryName
        case folderIndex = "folderIdx"
        case folderName
        case folderType
        case folderUpdatedAt
        case likeCount = "likeFolderCount"
        case likeStatus
        case linkCount = "folderLinkCount"
        case linkImageURL = "linkImageUrl"
        case updatedAt
        case userIndex = "userIdx"
    }
//
//    enum FolderType: String, Codable {
//        case privateFolder = "private"
//        case publicFolder = "public"
//    }
  
    init(userIndex: Int, folderIndex: Int, categoryIndex: Int, folderName: String, folderType: String, folderUpdatedAt: String, likeCount: Int, linkCount: Int, linkImageURL: String, likeStatus: Int, categoryName: String, detailCategoryIndex: Int, detailCategoryName: String, updatedAt: String) {
        
        self.folderIndex = folderIndex
        self.userIndex = userIndex
        self.categoryIndex = categoryIndex
        self.categoryName = categoryName
        self.detailCategoryIndex = detailCategoryIndex
        self.detailCategoryName = detailCategoryName
        self.folderName = folderName
        self.folderType = folderType
        self.folderUpdatedAt = folderUpdatedAt
        self.likeCount = likeCount
        self.linkCount = linkCount
        self.linkImageURL = linkImageURL
        self.likeStatus = likeStatus
        self.updatedAt = updatedAt
    }
    
    init() {
        self.init(userIndex: 0, folderIndex: 0, categoryIndex: 0, folderName: "", folderType: "", folderUpdatedAt: "", likeCount: 0, linkCount: 0, linkImageURL: "", likeStatus: 0, categoryName: "", detailCategoryIndex: 0, detailCategoryName: "", updatedAt: "")
    }
}
