//
//  RegisterDetailCategoryViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/19.
//

import UIKit

class RegisterDetailCategoryViewController: UIViewController {
    
    @IBOutlet private weak var detailCategoryCollectionView: UICollectionView!
    @IBOutlet private weak var detailCategoryCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nextButtonView: UIView!
    @IBOutlet private weak var nextButtonLabel: UILabel!
    
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var currentProgressView: UIView!
    
    private let registerViewModel: RegisterViewModel = RegisterViewModel()
    private var isNextButtonTapped: Bool = false
    private var isSkipButtonTapped: Bool = false
    
    private var detailCatgoryNumber: Int = -1 {
        didSet {
            nextButtonLabel.textColor = UIColor.white
            nextButtonView.backgroundColor = UIColor.linkMoaDarkBlueColor
            nextButtonView.isUserInteractionEnabled = true
        }
    }
    
    // 이전 VC 에서 데이터 주입
    var detailCategoryNumbers: [Int] = []
    var detailCategories: [String] = []
    
    var nickName: String = ""
    var categoryName: String = ""
    var categoryNumber: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareProgressViews()
        prepareNextButtonView()
        prepareCategoryCollectionView()
    }
    
    private func prepareNextButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonViewTapped))
        nextButtonView.isUserInteractionEnabled = false
        nextButtonView.addGestureRecognizer(tapGesture)
        nextButtonView.layer.masksToBounds = true
        nextButtonView.layer.cornerRadius = 8
    }
    
    private func prepareProgressViews() {
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 2
        currentProgressView.layer.masksToBounds = true
        currentProgressView.layer.cornerRadius = 2
    }
    
    private func prepareCategoryCollectionView() {
        detailCategoryCollectionView.register(UINib(nibName: SelectCategoryCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: SelectCategoryCell.cellIdentifier)
        detailCategoryCollectionView.dataSource = self
        detailCategoryCollectionView.delegate = self
        
        detailCategoryCollectionViewHeightConstraint.constant = CGFloat((detailCategories.count / 2 + detailCategories.count % 2) * 67)
    }
    
    private func moveHomeVC() {
        guard let homeVC = HomeViewController.storyboardInstance(),
              let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        
        let homeNC = HomeNavigationController(rootViewController: homeVC)
        
        window.rootViewController = homeNC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    @objc private func nextButtonViewTapped() {
        guard !isNextButtonTapped else { return }
        isNextButtonTapped = true

        let param: [String: Any] = [
            // "userNickname": nickName,
            "userCategoryIdx": categoryNumber,
            "userDetailCategoryIdx": detailCatgoryNumber
        ]
        
        registerViewModel.inputs.patchUserInformation(params: param, completion: { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let userInformation):
                print(userInformation)
                self.moveHomeVC()
                self.isNextButtonTapped = false
            case .failure(let error):
                print(error)
                self.isNextButtonTapped = false
            }
        })
    }
    
    @IBAction private func skipButtonTapped() {
        guard !isSkipButtonTapped else { return }
        isSkipButtonTapped = true
        
        let param: [String: Any] = [
            // "userNickname" : nickName,
            "userCategoryIdx": categoryNumber
        ]
        
        registerViewModel.inputs.patchUserInformation(params: param, completion: { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let userInformation):
                print(userInformation)
                self.moveHomeVC()
                self.isNextButtonTapped = true
            case .failure(let error):
                print(error)
                self.isSkipButtonTapped = false
            }
        })
    }
}

extension RegisterDetailCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCategoryCell.cellIdentifier, for: indexPath) as? SelectCategoryCell else { fatalError() }
        
        categoryCell.update(title: detailCategories[indexPath.item])
        return categoryCell
    }
}

extension RegisterDetailCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if detailCategoryNumbers.count == 1 {
            let width: CGFloat = (collectionView.bounds.width - (19 * 2) - 13)
            let height: CGFloat = 54
            return CGSize(width: width, height: height)
        }
        
        let width: CGFloat = (collectionView.bounds.width - (19 * 2) - 13) / 2
        let height: CGFloat = 54
        
        return CGSize(width: width, height: height)
    }
}

extension RegisterDetailCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cells = collectionView.visibleCells as? [SelectCategoryCell] else { return }
        print(indexPath)
        for cell in cells {
            cell.isSelectedCell = false
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectCategoryCell else { return }
        
        cell.isSelectedCell = true
        detailCatgoryNumber = detailCategoryNumbers[indexPath.item]
    }
}
