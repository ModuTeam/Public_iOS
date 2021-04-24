//
//  LikedFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation

//좋아요한 폴더 조회(리스트)
struct LikedFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [Result]?
    
    struct Result: Codable {
        let userIndex, categoryIndex: Int
        let categoryName: String
        let detailCategoryIndex: Int
        let detailCategoryName: String
        let folderIndex, folderLinkCount: Int
        let folderName, folderType: String
        let likeFolderCount: Int
        let linkImageURL: String
        let likeStatus: Int
        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case userIndex = "userIdx"
            case categoryIndex = "categoryIdx"
            case categoryName
            case detailCategoryIndex = "detailCategoryIdx"
            case detailCategoryName
            case folderIndex = "folderIdx"
            case folderLinkCount, folderName, folderType, likeFolderCount
            case linkImageURL = "linkImageUrl"
            case likeStatus,updatedAt
        }
    }
}
