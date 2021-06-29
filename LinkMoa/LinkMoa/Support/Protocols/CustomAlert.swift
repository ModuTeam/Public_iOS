//
//  CustomAlert.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/27.
//

import UIKit

enum Reconfirm {
    case reportFolder
    case deleteAccount
    case logout
}

enum TextRequest {
    case removeFolder
    case editNickname
}

enum ImageAlert {
    case saveFolder
    case editNickname
    case reportFolder
    case removeFolder
}

protocol CustomAlert: BackgroundBlur {}

extension CustomAlert where Self: UIViewController {
    
    var blurVC: BackgroundBlur {
        if let navi = navigationController as? BackgroundBlur {
            return navi
        } else { return self }
    }
    
    func presentImageAlertView(type: ImageAlert = .saveFolder, completion: (() -> Void)? = nil) {
        guard let imageAlertVC = ImageAlertViewController.storyboardInstance() else { return }
        
        imageAlertVC.modalPresentationStyle = .overCurrentContext
        imageAlertVC.modalTransitionStyle = .coverVertical
        imageAlertVC.blurVC = blurVC
        imageAlertVC.succeed = type
        imageAlertVC.completion = completion
        
        self.present(imageAlertVC, animated: true, completion: nil)
    }
    
    func presentTextRequestView(type: TextRequest = .removeFolder, name: String, completion: ((Any?) -> Void)?) {
        guard let textRequestVC = TextRequestViewController.storyboardInstance() else { return }
        
        textRequestVC.modalPresentationStyle = .overCurrentContext
        textRequestVC.modalTransitionStyle = .coverVertical
        textRequestVC.blurVC = blurVC
        textRequestVC.name = name
        textRequestVC.removeRequest = type
        textRequestVC.completion = completion
        
        self.present(textRequestVC, animated: true, completion: nil)
    }
    
    func presentReconfirmView(type: Reconfirm, completion: (() -> Void)?) {
        guard let reconfirmVC = ReconfirmViewController.storyboardInstance() else { return }
       
        reconfirmVC.blurVC = blurVC
        reconfirmVC.modalPresentationStyle = .overCurrentContext
        reconfirmVC.modalTransitionStyle = .coverVertical
        reconfirmVC.completion = completion
        reconfirmVC.reconfirm = type
        
        self.present(reconfirmVC, animated: true, completion: nil)
    }
}
