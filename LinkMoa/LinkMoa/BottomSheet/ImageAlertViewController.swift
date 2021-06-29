//
//  SaveSucceedBottomViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/20.
//

import UIKit

final class ImageAlertViewController: UIViewController {
    typealias ImageAlertTuple = (title: String, message: String, isPositive: Bool)
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var garibiImageView: UIImageView!
    
    private let titleMessage: [ImageAlert: ImageAlertTuple] = [
        .removeFolder: ("나의 가리비가 완전히 사라졌어요!", "삭제가 완료되었습니다.", false),
        .editNickname: ("나의 닉네임을 변경했어요.", "저장이 완료되었습니다.", true),
        .reportFolder: ("링크달 신고를 완료했어요!", "심사일까지 일주일이 소요될 수 있습니다.", false),
        .saveFolder: ("나의 가리비를 안전하게 보관했어요!", "저장이 완료되었습니다.", true)
    ]
    
    var blurVC: BackgroundBlur?
    var succeed: ImageAlert = .saveFolder
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentAndFadeIn()
        prepareUI()
        prepareBackgroundView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preparebottomViewRoundCorner()
    }
    
    private func prepareUI() {
        titleLabel.text = titleMessage[succeed]!.title
        subTitleLabel.text = titleMessage[succeed]!.message
        garibiImageView.image = titleMessage[succeed]!.isPositive ? UIImage(named: "garibiWithStar") : UIImage(named: "garibiWithSad")
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
    
    func presentAndFadeIn() {
        blurVC?.fadeInBackgroundViewAnimation()
    }
    
    private func dismissAndFadeOut() {
        blurVC?.fadeOutBackgroundViewAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func backgroundViewTapped() {
        dismissAndFadeOut()
    }
    
    @IBAction func dismissButtonTapped() {
        dismissAndFadeOut()
    }
}
