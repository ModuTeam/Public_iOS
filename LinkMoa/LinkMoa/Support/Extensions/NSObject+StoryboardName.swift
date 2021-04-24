//
//  NSObject+StoryboardName.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/24.
//

import Foundation

public extension NSObject {
    static func storyboardName() -> String {
        return String(describing: self).replacingOccurrences(of: "ViewController", with: "").replacingOccurrences(of: "NavigationController", with: "")
    }
}
