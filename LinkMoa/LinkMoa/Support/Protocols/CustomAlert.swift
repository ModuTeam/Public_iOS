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

enum RemoveRequest {
    case removeFolder
    case editNickname
}

enum Succeed {
    case saveFolder
    case editNickname
}

protocol CustomAlert {}

extension CustomAlert where Self: UIViewController {
    func alertSucceedView(type: Succeed = .saveFolder, completeHandler: (() -> ())?) {
        guard let saveSucceedBottomVC = SaveSucceedBottomViewController.storyboardInstance() else { return }
        
        saveSucceedBottomVC.modalPresentationStyle = .overCurrentContext
        saveSucceedBottomVC.modalTransitionStyle = .coverVertical
        saveSucceedBottomVC.completionHandler = completeHandler
        saveSucceedBottomVC.succeed = type
        
        self.present(saveSucceedBottomVC, animated: true, completion: nil)
    }
    
    func alertRemoveSucceedView(completeHandler: (() -> ())?) {
        guard let removeSucceedBottomVC = RemoveSucceedBottomViewController.storyboardInstance() else { return }
        
        removeSucceedBottomVC.modalPresentationStyle = .overCurrentContext
        removeSucceedBottomVC.modalTransitionStyle = .coverVertical
        removeSucceedBottomVC.completionHandler = completeHandler

        self.present(removeSucceedBottomVC, animated: true, completion: nil)
    }
    
    func alertRemoveRequestView(type: RemoveRequest = .removeFolder, folderName: String, completeHandler: (() -> ())?, removeHandler: (() -> ())?) {
        guard let removeRequestVC = RemoveRequestBottomViewController.storyboardInstance() else { return }
        
        removeRequestVC.modalPresentationStyle = .overCurrentContext
        removeRequestVC.modalTransitionStyle = .coverVertical
        removeRequestVC.completionHandler = completeHandler
        removeRequestVC.removeHandler = removeHandler
        removeRequestVC.folderName = folderName
        removeRequestVC.removeRequest = type
        
        self.present(removeRequestVC, animated: true, completion: nil)
    }
    
    func alertReconfirmRequestView(type: Reconfirm, animationHandler: (() -> ())?, completeHandler: (() -> ())?) {
        guard let reconfirmVC = ReconfirmBottomViewController.storyboardInstance() else { return }
        
        reconfirmVC.modalPresentationStyle = .overCurrentContext
        reconfirmVC.modalTransitionStyle = .coverVertical
        reconfirmVC.animationHandler = animationHandler
        reconfirmVC.completionHandler = completeHandler
        switch type {
        case .reportFolder:
            reconfirmVC.updateReportUI()
        case .deleteAccount:
            reconfirmVC.updateDeleteUI()
        case .logout:
            reconfirmVC.updateLogoutUI()
        }

        self.present(reconfirmVC, animated: true, completion: nil)
    }
    
    func alertReportSucceedView(completeHandler: (() -> ())?) {
        guard let removeSucceedBottomVC = RemoveSucceedBottomViewController.storyboardInstance() else { return }
        
        removeSucceedBottomVC.modalPresentationStyle = .overCurrentContext
        removeSucceedBottomVC.modalTransitionStyle = .coverVertical
        removeSucceedBottomVC.updateReportUI()
        removeSucceedBottomVC.completionHandler = completeHandler
        
        self.present(removeSucceedBottomVC, animated: true, completion: nil)
    }
    
//    func alertDeleteAccountRequestView(completeHandler: (() -> ())?, reportHandler: (() -> ())?) {
//        guard let reconfirmVC = ReconfirmBottomViewController.storyboardInstance() else { return }
//        
//        reconfirmVC.modalPresentationStyle = .overCurrentContext
//        reconfirmVC.modalTransitionStyle = .coverVertical
//        reconfirmVC.completionHandler = completeHandler
//        reconfirmVC.reportHandler = reportHandler
//        reconfirmVC.updateDeleteUI()
//
//        self.present(reconfirmVC, animated: true, completion: nil)
//    }

    
}
