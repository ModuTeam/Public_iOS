//
//  SearchMainNavigationController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/26.
//

import UIKit

class SearchMainNavigationController: UINavigationController, BackgroundBlur {

    static func storyboardInstance() -> SearchMainNavigationController? {
        let storyboard = UIStoryboard(name: SearchMainNavigationController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    var searchTarget: SearchTarget = .my
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
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

extension SearchMainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
