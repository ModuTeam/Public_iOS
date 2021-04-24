//
//  UserInformationResponse.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/19.
//

import Foundation

struct UserInformationResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let userIndex: Int?
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case isSuccess, code
        case userIndex = "userIdx"
        case message
    }
}
