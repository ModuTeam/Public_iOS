//
//  LikedFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation

/// 좋아요한 폴더 조회(리스트)
struct LikedFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [IntegratedFolder]?
}
