//
//  OpenSourceInfoViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/23.
//

import UIKit

class OpenSourceInfoViewController: UIViewController {

    static func storyboardInstance() -> OpenSourceInfoViewController? {
        let storyboard = UIStoryboard(name: OpenSourceInfoViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
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