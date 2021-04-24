//
//  ReconfirmBottomViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import UIKit

class ReconfirmBottomViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportButtonView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonLabel: UILabel!
    
    var folderIndex: Int?
    var animationHandler: (() -> ())?
    var completionHandler: (() -> ())?
    var mainTitle: String = "신고하기"
    var content: String = "링크달을 신고하시겠습니까?"
    var buttonTitle: String = "신고하기"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareBackGroundView()
        prepareBottomViewGesture()
        prepareDeleteButtonView()
        prepareLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareBottomViewRoundConer()
    }

    static func storyboardInstance() -> ReconfirmBottomViewController? {
        let storyboard = UIStoryboard(name: ReconfirmBottomViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func prepareLabel() {
        titleLabel.text = mainTitle
        reportLabel.text = content
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
    
    private func prepareBackGroundView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
    }
    
    @objc private func reportButtonViewTapped() {
        
        self.animationHandler?()
        
        dismiss(animated: true, completion: {
            self.completionHandler?()
        })
        
    }
    
    @objc private func backgroundViewTapped() {
        animationHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func bottomViewTapped() {
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        animationHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    func updateDeleteUI() {
        mainTitle = "탈퇴하기"
        content = "탈퇴 후에는 복구가 불가능하며 작성한 모든 데이터를 삭제하거나 수정할 수 없습니다."
        buttonTitle = "동의 후 탈퇴하기"
    }
    
    func updateReportUI() {
        mainTitle = "신고하기"
        content = "링크달을 신고하시겠습니까?"
        buttonTitle = "신고하기"
    }
    
    func updateLogoutUI() {
        mainTitle = "로그아웃"
        content = "로그아웃 하시겠습니까?"
        buttonTitle = "로그아웃"
    }
}

