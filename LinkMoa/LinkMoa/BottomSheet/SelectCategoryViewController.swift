//
//  SelectCategoryBottomViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/17.
//

import UIKit

class SelectCategoryViewController: UIViewController {

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var backGroundView: UIView!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var categoryCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var completionHandler: (() -> Void)?
    var selectionHandler: ((String, Int) -> Void)? // 카테고리 이름 / 카테고리 넘버
    
    var categoryNumbers: [Int] = []
    var categories: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareBackgroundView()
        prepareCategoryCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preparebottomViewRoundConer()
    }
    
    private func prepareCategoryCollectionView() {
        categoryCollectionView.register(UINib(nibName: SelectCategoryCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: SelectCategoryCell.cellIdentifier)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        categoryCollectionViewHeightConstraint.constant = CGFloat((categories.count / 2 + categories.count % 2) * 67)
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
    
    @objc private func backgroundViewTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
}

extension SelectCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCategoryCell.cellIdentifier, for: indexPath) as? SelectCategoryCell else { fatalError() }
        
        categoryCell.update(title: categories[indexPath.item])
        return categoryCell
    }
}

extension SelectCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.bounds.width - (19 * 2) - 14) / 2
        let height: CGFloat = 54
        
        return CGSize(width: width, height: height)
    }
}

extension SelectCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categoryNumber = categoryNumbers[indexPath.row]
        let categoryName = categories[indexPath.row]
        
        selectionHandler?(categoryName, categoryNumber)
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
}
