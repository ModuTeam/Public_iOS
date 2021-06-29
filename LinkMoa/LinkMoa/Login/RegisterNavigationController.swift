//
//  RegisterControllerController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/18.
//

import UIKit

class RegisterNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.isEnabled = false
    }
}
