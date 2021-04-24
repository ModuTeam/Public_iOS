//
//  RegisterCategoryViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/18.
//

import UIKit

class RegisterCategoryViewController: UIViewController {

    @IBOutlet private weak var nextButtonView: UIView!
    @IBOutlet private weak var nextButtonLabel: UILabel!
    @IBOutlet private weak var categoryStackView: UIStackView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var currentProgressView: UIView!
    @IBOutlet private var categoryHeightConstarintLayouts: [NSLayoutConstraint]!
    
    static func storyboardInstance() -> RegisterCategoryViewController? {
        let storyboard = UIStoryboard(name: RegisterCategoryViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private var detailCategoryData: [Int:[String:Int]] = [
        1 : [
            "서버" : 1,
            "웹" : 2,
            "iOS" : 3,
            "안드로이드" : 4,
            "자료구조/알고리즘" : 5,
            "게임" : 6,
            "빅데이터" : 7,
            "AI" : 8,
            "머신러닝" : 9,
            "기타" : 10,
        ],
        2 : [
            "UI/UX" : 11,
            "웹" : 12,
            "그래픽" : 13,
            "모바일" : 14,
            "광고" : 15,
            "BI/BX" : 16,
            "디자인리소스" : 17,
            "기타" : 18
        ],
        3 : [
            "디지털마케팅" : 19,
            "콘텐츠마케팅" : 20,
            "소셜마케팅" : 21,
            "브랜드마케팅" : 22,
            "제휴마케팅" : 23,
            "키워드광고" : 24,
            "기타" : 25,
        ],
        4 : [
            "일반" : 26,
            "서비스" : 27,
            "전략" : 28,
            "프로젝트" : 29,
            "기타" : 30,
        ],
        5 : ["기타" : -1]
    ]
    
    private var selectedNumber: Int = -1 {
        didSet {
            nextButtonLabel.textColor = UIColor.white
            nextButtonView.backgroundColor = UIColor.linkMoaDarkBlueColor
            nextButtonView.isUserInteractionEnabled = true
        }
    }
    
    var nickName: String = "" // 이전 VC 에서 데이터 주입
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareProgressViews()
        prepareStackViewSubviews()
        prepareNextButtonView()
    }
    
    private func prepareStackViewSubviews() {
        for subview in categoryStackView.subviews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
            subview.addGestureRecognizer(tapGesture)
            subview.isUserInteractionEnabled = true
            
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 8
        }
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136, 1334:
                for height in categoryHeightConstarintLayouts {
                    height.constant = 60
                }
            default:
                break
            }
        }
    }
    
    private func prepareProgressViews() {
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 2
        currentProgressView.layer.masksToBounds = true
        currentProgressView.layer.cornerRadius = 2
    }
    
    private func prepareNextButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonViewTapped))
        nextButtonView.isUserInteractionEnabled = false
        nextButtonView.addGestureRecognizer(tapGesture)
        nextButtonView.layer.masksToBounds = true
        nextButtonView.layer.cornerRadius = 8
    }
    
    @objc private func categoryTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        selectedNumber = view.tag
        print(selectedNumber)
        categoryStackView.subviews.forEach({
            if $0.tag != view.tag {
                $0.layer.opacity = 0.3
            } else {
                $0.layer.opacity = 1
            }
        })
    }
    
    @objc private func nextButtonViewTapped() {
        guard let registerDetailCategoryVC = RegisterDetailCategoryViewController.storyboardInstance() else { return }
        
        if let detailCategory = detailCategoryData[selectedNumber] {
            let sortedDetailCategoryData = detailCategory.sorted(by: { $0.1 < $1.1 })
            
            registerDetailCategoryVC.detailCategories = sortedDetailCategoryData.map { $0.key }
            registerDetailCategoryVC.detailCategoryNumbers = sortedDetailCategoryData.map { $0.value }
        }
        
        registerDetailCategoryVC.categoryNumber = selectedNumber
        registerDetailCategoryVC.nickName = nickName
        navigationController?.pushViewController(registerDetailCategoryVC, animated: true)
    }
    
}
