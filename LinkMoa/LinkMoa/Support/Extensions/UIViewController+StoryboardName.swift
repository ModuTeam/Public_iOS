//
//  UIViewController+.swift
//  RxMvvmBase
//
//  Created by Beomcheol Kwon on 2021/06/16.
//

import UIKit

public extension UIViewController {
    static func storyboardName() -> String {
        return String(describing: self).replacingOccurrences(of: "ViewController", with: "").replacingOccurrences(of: "NavigationController", with: "")
    }
    
    static func storyboardInstance() -> Self? {
        let storyboard = UIStoryboard(name: Self.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}
