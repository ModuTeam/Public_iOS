//
//  UserInfo.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/17.
//

import Foundation

struct UserInfo: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [Result]
    
    struct Result: Codable {
        let index, strategy: Int
        let nickname, email: String
        let profileImgURL: String
        let categoryIndex: Int
        
        enum CodingKeys: String, CodingKey {
            case index = "userIdx"
            case strategy = "userStrategy"
            case nickname = "userNickname"
            case email = "userEmail"
            case profileImgURL = "userProfileImgUrl"
            case categoryIndex = "userCategoryIdx"
        }
    }
}
