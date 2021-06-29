//
//  LinkResponse.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation

/// 폴더좋아요/취소, 링크 추가, 링크 수정, 링크 삭제
struct LinkResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let index: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case isSuccess, code
        case index = "userIdx"
        case message
    }
}
