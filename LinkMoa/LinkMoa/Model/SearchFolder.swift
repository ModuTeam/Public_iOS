//
//  SearchFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/10.
//

import Foundation

struct SearchFolder: Codable {
    let isSuccess: Bool
    let code, userIndex: Int
    let message: String
    let resultCount: Int
    let result: [IntegratedFolder]?
    
    enum CodingKeys: String, CodingKey {
        case isSuccess, code
        case userIndex = "userIdx"
        case message, resultCount, result
    }
}
