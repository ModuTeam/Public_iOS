//
//  NewFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation

/// 폴더 생성
struct NewFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let index: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case isSuccess, code
        case index = "folderIdx"
        case message
    }
}
