//
//  Report.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import Foundation

struct ReportResponse: Codable {
    let reportIndex: Int
    let isSuccess: Bool
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case reportIndex = "reportIdx"
        case isSuccess, code, message
    }
}
