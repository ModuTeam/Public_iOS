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
    let result: [IntegratedFolder]
    
    enum CodingKeys: String, CodingKey {
        case userIndex = "userIdx"
        case isSuccess, code, message, result
    }
}
