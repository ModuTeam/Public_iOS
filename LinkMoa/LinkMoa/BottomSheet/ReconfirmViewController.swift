//
//  ReconfirmBottomViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import UIKit

class ReconfirmViewController: UIViewController {
    typealias ReconfirmTuple = (title: String, message: String, buttonTitle: String)
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportButtonView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonLabel: UILabel!
    
    private let titleMessage: [Reconfirm: ReconfirmTuple] = [
        .reportFolder: ("신고하기", "링크달을 신고하시겠습니까?", "신고하기"),
        .logout: ("로그아웃", "로그아웃 하시겠습니까?", "로그아웃"),
        .deleteAccount: ("탈퇴하기", "탈퇴 후에는 복구가 불가능하며 작성한 모든 데이터를 삭제하거나 수정할 수 없습니다.", "동의 후 탈퇴하기")
    ]
    
    var reconfirm: Reconfirm = .reportFolder
    var completion: (() -> Void)?
    var folderIndex: Int?
    var blurVC: BackgroundBlur?
      
    override func viewDidLoad() {
        super.viewDidLoad()
        presentAndFadeIn()
        prepareUI()
        prepareBackgroundView()
        prepareBottomViewGesture()
        prepareDeleteButtonView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareBottomViewRoundConer()
    }
    
    private func prepareUI() {
        guard let title = titleMessage[reconfirm]?.title else { return }
        guard let message = titleMessage[reconfirm]?.message else { return }
        guard let buttonTitle = titleMessage[reconfirm]?.buttonTitle else { return }
        titleLabel.text = title
        reportLabel.text = message
        buttonLabel.text = buttonTitle
    }
    
    private func prepareDeleteButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reportButtonViewTapped))
        reportButtonView.addGestureRecognizer(tapGesture)
        reportButtonView.isUserInteractionEnabled = true
        
        reportButtonView.layer.masksToBounds = true
        reportButtonView.layer.cornerRadius = 8
        reportButtonView.layer.borderWidth = 1
        reportButtonView.layer.borderColor = UIColor.linkMoaRedColor.cgColor
    }
    
    private func prepareBottomViewRoundConer() {
        bottomView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        bottomView.clipsToBounds = true
    }
    
    private func prepareBottomViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomViewTapped))
        tapGesture.cancelsTouchesInView = false
        bottomView.addGestureRecognizer(tapGesture)
        bottomView.isUserInteractionEnabled = true
    }
    
    private func prepareBackgroundView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
    }
    
    @objc private func reportButtonViewTapped() {
        completion?()
        dismissAndFadeOut()
    }
    
    func presentAndFadeIn() {
        blurVC?.fadeInBackgroundViewAnimation()
    }
    
    func dismissAndFadeOut() {
        blurVC?.fadeOutBackgroundViewAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func backgroundViewTapped() {
        dismissAndFadeOut()
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismissAndFadeOut()      
    }
    
    @objc private func bottomViewTapped() {
        
    }
}
