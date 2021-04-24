//
//  RemoveSucceedBottomViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/20.
//

import UIKit

final class RemoveSucceedBottomViewController: UIViewController {

    @IBOutlet private var bottomView: UIView!
    @IBOutlet private var backGroundView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    var mainTitle: String = "나의 가리비가 완전히 사라졌어요!"
    var subTitle: String = "삭제가 완료되었습니다."
    
    var completionHandler: (() -> ())?
    
    static func storyboardInstance() -> RemoveSucceedBottomViewController? {
        let storyboard = UIStoryboard(name: RemoveSucceedBottomViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareBackgroundView()
        prepareLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preparebottomViewRoundConer()
    }
    
    private func preparebottomViewRoundConer() {
        bottomView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        bottomView.clipsToBounds = true
    }
    
    private func prepareBackgroundView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backGroundView.addGestureRecognizer(tapGesture)
        backGroundView.isUserInteractionEnabled = true
    }
    
    private func prepareLabel() {
        mainTitleLabel.text = mainTitle
        subTitleLabel.text = subTitle
    }
    
    @objc private func backgroundViewTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    func updateReportUI() {
        mainTitle = "링크달 신고를 완료했어요!"
        subTitle = "심사일까지 일주일이 소요될 수 있습니다."
    }
}
