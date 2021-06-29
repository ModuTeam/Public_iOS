//
//  AddFolderCategoryViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/17.
//

import UIKit
import Toast_Swift

final class AddFolderCategoryViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var previousButtonView: UIView!
    @IBOutlet private weak var saveButtonView: UIView!
    
    @IBOutlet private weak var categoryView: UIView!
    @IBOutlet private weak var categorySelectionLabel: UILabel!
    @IBOutlet private weak var categoryPlaceholderLabel: UILabel!
    
    @IBOutlet private weak var detailCategoryView: UIView!
    @IBOutlet private weak var detailCategorySelectionLabel: UILabel!
    @IBOutlet private weak var detailCategoryPlaceholderLabel: UILabel!
    
    private let addFolderViewModel: AddFolderViewModel = AddFolderViewModel()

    private var blurVC: AddFolderNavigationController? {
        return navigationController as? AddFolderNavigationController
    }
    
    private var categoryData: [String: Int] = [
        "개발": 1,
        "디자인": 2,
        "마케팅/광고": 3,
        "기획": 4,
        "기타": 5
    ]
    
    private var detailCategoryData: [Int: [String: Int]] = [
        1: [
            "서버": 1,
            "웹": 2,
            "iOS": 3,
            "안드로이드": 4,
            "자료구조/알고리즘": 5,
            "게임": 6,
            "빅데이터": 7,
            "AI": 8,
            "머신러닝": 9,
            "기타": 10
        ],
        2: [
            "UI/UX": 11,
            "웹": 12,
            "그래픽": 13,
            "모바일": 14,
            "광고": 15,
            "BI/BX": 16,
            "디자인리소스": 17,
            "기타": 18
        ],
        3: [
            "디지털마케팅": 19,
            "콘텐츠마케팅": 20,
            "소셜마케팅": 21,
            "브랜드마케팅": 22,
            "제휴마케팅": 23,
            "키워드광고": 24,
            "기타": 25
        ],
        4: [
            "일반": 26,
            "서비스": 27,
            "전략": 28,
            "프로젝트": 29,
            "기타": 30
        ]
    ]
    
    var categoryName: String = "" { // 대분류
        didSet {
            guard let categorySelectionLabel = categorySelectionLabel else { return }
            guard let detailCategoryPlaceholderLabel = detailCategoryPlaceholderLabel else { return }
            guard let categoryPlaceholderLabel = categoryPlaceholderLabel else { return }
            guard let detailCategorySelectionLabel = detailCategorySelectionLabel else { return }
            
            categorySelectionLabel.isHidden = false
            categorySelectionLabel.text = categoryName
            categoryPlaceholderLabel.isHidden = true
            
            if categoryName == "기타" {
                detailCategoryNumber = 0
                detailCategoryName = ""
                detailCategorySelectionLabel.isHidden = true
                detailCategoryPlaceholderLabel.isHidden = false
            } 
        }
    }
    
    var categoryNumber: Int = 0 // 대분류 넘버
    
    var detailCategoryName: String = "" { // 중분류
        didSet {
            guard let detailCategorySelectionLabel = detailCategorySelectionLabel else { return }
            guard let detailCategoryPlaceholderLabel = detailCategoryPlaceholderLabel else { return }
            detailCategorySelectionLabel.isHidden = false
            detailCategorySelectionLabel.text = detailCategoryName
            detailCategoryPlaceholderLabel.isHidden = true
        }
    }
    
    var detailCategoryNumber: Int = 0 // 중분류 넘버
    
    // edit 할 때 사용하는 값들
    var folder: FolderDetail.Result?
    var folderIndex: Int?
    
    // add 할 때 사용하는 클로저 -> 사용자가 카테고리를 선택하고 이전을 눌렀을 때 다시 불러옴
    var saveCategory: ((String, Int) -> Void)?
    var saveDetailCategory: ((String, Int) -> Void)?
    
    // Folder VC 와 관련된 클로저
    var alertSucceedViewHandler: (() -> Void)? // PresetingVC 성공 Alert 보여줄 때
    
    var folderPresentingType: FolderPresentingType = .add
    var folderName: String?
    var tags: [String]?
    var isShared: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
        prepareCategoryView()
        prepareDetailCategoryView()
        prepareSaveButtonView()
        preparePreviousButtonView()
    }
    
    private func update() {
        switch folderPresentingType {
        case .edit:
            guard let folder = folder else { return }
            titleLabel.text = "폴더 수정"
            
            if folder.categoryIndex != -1, folder.categoryName != "-1" {
                categoryName = folder.categoryName
                categoryNumber = folder.categoryIndex
            }
            
            if let detailCategoryIndex = folder.detailCategoryIndex,
               detailCategoryIndex != -1,
               let detailCategoryName = folder.detailCategoryName,
               detailCategoryName != "-1" {
                
                self.detailCategoryName = detailCategoryName
                self.detailCategoryNumber = detailCategoryIndex
            }
        case .add:
            if categoryName != "" {
                let temp = categoryName
                self.categoryName = temp
            }
            
            if detailCategoryName != "" {
                let temp = detailCategoryName
                self.detailCategoryName = temp
            }
        }
    }
    
    private func prepareSaveButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped))
        saveButtonView.addGestureRecognizer(tapGesture)
        saveButtonView.isUserInteractionEnabled = true
        
        saveButtonView.layer.masksToBounds = true
        saveButtonView.layer.cornerRadius = 8
    }
    
    private func prepareCategoryView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryViewTapped))
        categoryView.addGestureRecognizer(tapGesture)
        categoryView.isUserInteractionEnabled = true
        
        categoryView.layer.masksToBounds = true
        categoryView.layer.cornerRadius = 8
        categoryView.layer.borderColor = UIColor.linkMoaFolderSeletionBorderColor.cgColor
        categoryView.layer.borderWidth = 1
    }
    
    private func prepareDetailCategoryView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detailCategoryViewTapped))
        detailCategoryView.addGestureRecognizer(tapGesture)
        detailCategoryView.isUserInteractionEnabled = true
        
        detailCategoryView.layer.masksToBounds = true
        detailCategoryView.layer.cornerRadius = 8
        detailCategoryView.layer.borderColor = UIColor.linkMoaFolderSeletionBorderColor.cgColor
        detailCategoryView.layer.borderWidth = 1
    }
    
    private func preparePreviousButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previousButtonViewTapped))
        previousButtonView.addGestureRecognizer(tapGesture)
        previousButtonView.isUserInteractionEnabled = true
        
        previousButtonView.layer.masksToBounds = true
        previousButtonView.layer.cornerRadius = 8
        previousButtonView.layer.borderWidth = 1
        previousButtonView.layer.borderColor = UIColor.linkMoaDarkBlueColor.cgColor
    }
    
    @objc private func categoryViewTapped() {
        guard let selectCategoryBottomVC = SelectCategoryViewController.storyboardInstance() else { return }
        let sortedCategoryData = categoryData.sorted(by: { $0.1 < $1.1 })
        
        selectCategoryBottomVC.modalPresentationStyle = .overCurrentContext
        selectCategoryBottomVC.modalTransitionStyle = .coverVertical
        selectCategoryBottomVC.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.blurVC?.fadeOutBackgroundViewAnimation()
        }
        selectCategoryBottomVC.selectionHandler = { [weak self] name, number in
            guard let self = self else { return }
            self.categoryName = name
            self.categoryNumber = number
            self.saveCategory?(name, number)
        }
        
        selectCategoryBottomVC.categories = sortedCategoryData.map { $0.key }
        selectCategoryBottomVC.categoryNumbers = sortedCategoryData.map { $0.value }
        
        blurVC?.fadeInBackgroundViewAnimation()
        present(selectCategoryBottomVC, animated: true, completion: nil)
    }
    
    @objc private func detailCategoryViewTapped() {
        guard let selectCategoryBottomVC = SelectCategoryViewController.storyboardInstance() else { return }
        
        guard categoryName != "" || categoryNumber != 0 else {
            view.makeToast("먼저 카테고리를 선택해주세요.", position: ToastPosition.top)
            return
        }
        
        guard let detailCategory = detailCategoryData[categoryNumber] else { return }
        let sortedDetailCategoryData = detailCategory.sorted(by: { $0.1 < $1.1 })
        
        selectCategoryBottomVC.modalPresentationStyle = .overCurrentContext
        selectCategoryBottomVC.modalTransitionStyle = .coverVertical
        selectCategoryBottomVC.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.blurVC?.fadeOutBackgroundViewAnimation()
        }
        selectCategoryBottomVC.selectionHandler = { [weak self] name, number in
            guard let self = self else { return }
            self.detailCategoryName = name
            self.detailCategoryNumber = number
            self.saveDetailCategory?(name, number)
        }
        
        selectCategoryBottomVC.categories = sortedDetailCategoryData.map { $0.key }
        selectCategoryBottomVC.categoryNumbers = sortedDetailCategoryData.map { $0.value }
        
        blurVC?.fadeInBackgroundViewAnimation()
        present(selectCategoryBottomVC, animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = folderName, let tags = tags, let isShared = isShared else { return }
        
        if isShared == true { // 공개 상태일 때는 카테고리를 강제함
            if categoryNumber == 0 {
                view.makeToast("카테고리를 선택해주세요.", position: ToastPosition.top)
                return
            }
            
            if categoryNumber != 5, detailCategoryNumber == 0 {
                view.makeToast("상세 카테고리를 선택해주세요.", position: ToastPosition.top)
                return
            }
        }

        switch folderPresentingType {
        case .add:
            var params: [String: Any] = ["folderName": name,
                                         "hashTagList": tags,
                                         "folderType": isShared == true ? "public": "private"
            ]
            
            if isShared == true { // 공개 상태
                if categoryNumber == 5 {
                    params["categoryIdx"] = categoryNumber
                } else {
                    params["categoryIdx"] = categoryNumber
                    params["detailCategoryIdx"] = detailCategoryNumber
                }
            } else { // 비공개 상태
                if categoryNumber != 0, detailCategoryNumber != 0 {
                    if categoryNumber == 5 {
                        params["categoryIdx"] = categoryNumber
                    } else {
                        params["categoryIdx"] = categoryNumber
                        params["detailCategoryIdx"] = detailCategoryNumber
                    }
                }
            }
            
            addFolderViewModel.addFolder(folderParam: params, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let value):
                    if value.isSuccess {
                        self.dismiss(animated: true, completion: {
                            self.alertSucceedViewHandler?()
                        })
                    }
                case .failure(let error):
                    print(error)
                }
            })
        case .edit:
            guard let folderIndex = folder?.folderIndex else { return }
            
            var params: [String: Any] = ["folderName": name,
                                         "hashTagList": tags,
                                         "folderType": isShared == false ? "private" : "public"
            ]
            
            if categoryNumber == 5 {
                params["categoryIdx"] = categoryNumber
            } else {
                params["categoryIdx"] = categoryNumber
                params["detailCategoryIdx"] = detailCategoryNumber
            }
            
            addFolderViewModel.inputs.editFolder(folder: folderIndex, params: params, completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let folderResponse):
                    if folderResponse.isSuccess {
                        self.dismiss(animated: true, completion: {
                            self.alertSucceedViewHandler?() // 수정 성공했을 때 사용
                        })
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    @objc private func previousButtonViewTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
