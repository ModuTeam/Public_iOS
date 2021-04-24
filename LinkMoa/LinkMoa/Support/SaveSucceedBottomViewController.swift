//
//  SaveSucceedBottomViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/20.
//

import UIKit

final class SaveSucceedBottomViewController: UIViewController {

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    var succeed: Succeed = .saveFolder
    var completionHandler: (() -> ())?

    static func storyboardInstance() -> SaveSucceedBottomViewController? {
        let storyboard = UIStoryboard(name: SaveSucceedBottomViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTitleLabels()
        prepareBackgroundView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preparebottomViewRoundCorner()
    }
    
    private func prepareTitleLabels() {
        switch succeed {
        case .editNickname:
            titleLabel.text = "나의 닉네임을 변경했어요."
        default:
            break
        }
    }
    
    private func prepareBackgroundView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
    }
    
    private func preparebottomViewRoundCorner() {
        bottomView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        bottomView.clipsToBounds = true
    }
    
    @objc private func backgroundViewTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
}
