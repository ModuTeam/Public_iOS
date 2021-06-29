//
//  MyPageNavigationController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/19.
//

import UIKit

class MyPageNavigationController: UINavigationController, BackgroundBlur {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
     
    }
    private func prepareNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = UIColor.clear
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: -3, right: 0))
    }
}
