//
//  SearchLink.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/11.
//

import Foundation

struct SearchLink: Codable {
    let isSuccess: Bool
    let code, userIdx: Int
    let message: String
    let resultCount: Int
    let result: [Result]?
    
    struct Result: Codable {
        let linkIndex, folderIndex, userIndex: Int
        let name: String
        let url: String
        let imageURL: String
        let faviconURL: String
        let folderUpdatedAt: String

        enum CodingKeys: String, CodingKey {
            case linkIndex = "linkIdx"
            case folderIndex = "folderIdx"
            case userIndex = "userIdx"
            case name = "linkName"
            case url = "linkUrl"
            case imageURL = "linkImageUrl"
            case faviconURL = "linkFaviconUrl"
            case folderUpdatedAt
        }
    }
}
