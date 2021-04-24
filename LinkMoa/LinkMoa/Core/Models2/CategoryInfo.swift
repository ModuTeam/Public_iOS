//
//  CategoryInfo.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/17.
//

import Foundation

struct CategoryInfo: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [Result]

    struct Result: Codable {
        let index: Int
        let name: String
        let detailList: [DetailCategoryList]
        
        enum CodingKeys: String, CodingKey {
            case index = "categoryIdx"
            case name = "categoryName"
            case detailList = "detailCategoryList"
        }
    }

    struct DetailCategoryList: Codable {
        let detailIndex: Int
        let detailName: String
        
        enum CodingKeys: String, CodingKey {
            case detailIndex = "detailCategoryIdx"
            case detailName = "detailCategoryName"
        }
    }

}

