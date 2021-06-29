//
//  UsersFolder.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/29.
//

import Foundation

struct UsersFolder: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [IntegratedFolder]
}
