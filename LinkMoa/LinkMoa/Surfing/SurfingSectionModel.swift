//
//  SurfingSectionModel.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/08.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

enum SurfingSectionModel {
    case topTenSection(items: [SurfingSectionItem])
    case categorySection(items: [SurfingSectionItem])
    case likedSection(items: [SurfingSectionItem])
}

enum SurfingSectionItem {
    case topTenItem(folder: IntegratedFolder)
    case categoryItem(index: Int)
    case likedItem(folder: IntegratedFolder)
}

extension SurfingSectionModel: SectionModelType {
    typealias Item = SurfingSectionItem
    
    var items: [SurfingSectionItem] {
        switch self {
        case .topTenSection(items: let items):
            return items
        case .categorySection(items: let items):
            return items
        case .likedSection(items: let items):
            return items
        }
    }
    
    init(original: SurfingSectionModel, items: [Item]) {
        switch original {
        case .topTenSection(items: _):
            self = .topTenSection(items: items)
        case .categorySection(items: _):
            self = .categorySection(items: items)
        case .likedSection(items: _):
            self = .likedSection(items: items)
        }
    }
}
