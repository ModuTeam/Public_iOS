//
//  SplashViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/20.
//

import UIKit

class SplashViewController: UIViewController {

    static func storyboardInstance() -> SplashViewController? {
        let storyboard = UIStoryboard(name: SplashViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
