//
//  FolderDetail.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//
import Foundation

// 폴더상세조회
struct FolderDetail: Codable {
    
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: Result?
    
    init() {
        self.isSuccess = false
        self.code = 0
        self.message = ""
        self.result = .init()
    }
    
    struct Result: Codable {

        init() {
            self.init(userIndex: 0, userNickname: "", folderIndex: 0, name: "", type: "", likeCount: 0, linkCount: 0, folderUpdatedAt: "", likeStatus: 0, hashTagList: [], linkList: [], categoryIndex: 0, categoryName: "", detailCategoryIndex: 0, detailCategoryName: "")
        }
        
        init(userIndex: Int, userNickname: String, folderIndex: Int, name: String, type: String, likeCount: Int, linkCount: Int, folderUpdatedAt: String, likeStatus: Int, hashTagList: [HashTag], linkList: [Link], categoryIndex: Int, categoryName: String, detailCategoryIndex: Int, detailCategoryName: String) {
            self.userIndex = userIndex
            self.userNickname = userNickname
            self.folderIndex = folderIndex
            self.name = name
            self.type = type
            self.likeCount = likeCount
            self.linkCount = linkCount
            self.folderUpdatedAt = folderUpdatedAt
            self.likeStatus = likeStatus
            self.hashTagList = hashTagList
            self.linkList = linkList
            self.categoryIndex = categoryIndex
            self.categoryName = categoryName
            self.detailCategoryIndex = detailCategoryIndex
            self.detailCategoryName = detailCategoryName
        }
        
        let userIndex: Int
        let userNickname: String
        let folderIndex: Int
        let name, type: String
        let likeCount, linkCount: Int
        let folderUpdatedAt: String
        let likeStatus: Int
        let hashTagList: [HashTag]
        let linkList: [Link]
        let categoryIndex: Int
        let categoryName: String
        let detailCategoryIndex: Int?
        let detailCategoryName: String?

        enum CodingKeys: String, CodingKey {
            case userIndex = "userIdx"
            case userNickname = "userNickname"
            case folderIndex = "folderIdx"
            case name = "folderName"
            case type = "folderType"
            case likeCount = "folderLikeCount"
            case linkCount = "folderLinkCount"
            case categoryIndex = "categoryIdx"
            case detailCategoryIndex = "detailCategoryIdx"
            case folderUpdatedAt, likeStatus, hashTagList, linkList, categoryName, detailCategoryName // detailcategoryName
        }
    }
    
    struct HashTag: Codable {
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case name = "tagName"
        }
    }
    
    struct Link: Codable, Equatable {
        let index: Int
        let name: String
        let url: String
        let faviconURL: String
        let updateDate: String
        
        enum CodingKeys: String, CodingKey {
            case index = "linkIdx"
            case name = "linkName"
            case url = "linkUrl"
            case faviconURL = "linkFaviconUrl"
            case updateDate = "linkUpdatedAt"
        }
        
        static func == (lhs: Link, rhs: Link) -> Bool {
            return lhs.index == rhs.index
        }
    }
}
