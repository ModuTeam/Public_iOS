//
//  FolderResponse.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/08.
//

import Foundation

/// 폴더 수정, 폴더 삭제
struct FolderResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
}

