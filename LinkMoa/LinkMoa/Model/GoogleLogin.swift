//
//  GoogleLogin.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/08.
//

import Foundation

struct GoogleLogin: Codable {    
    struct Response: Codable {
        let isSuccess: Bool
        let code: Int
        let message: String
        let result: Result?
    }
    
    struct Result: Codable {
        let jwt: String
        let userIndex: Int?
        let member: String
        
        enum CodingKeys: String, CodingKey {
            case userIndex = "userIdx"
            case jwt
            case member
        }
    }
}
