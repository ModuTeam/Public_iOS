//
//  CategoryFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/15.
//

import Foundation

enum FolderType: String, Codable {
    case privateFolder = "private"
    case publicFolder = "public"
}

struct CategoryFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: Result
    
    struct Result: Codable {
        let count: Int
        let list: [IntegratedFolder]
        
        enum CodingKeys: String, CodingKey {
            case count = "folderCount"
            case list = "folderList"
        }
    }
}
