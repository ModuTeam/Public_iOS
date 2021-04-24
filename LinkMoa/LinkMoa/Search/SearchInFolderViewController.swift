//
//  SearchLinkViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/23.
//

import UIKit

final class SearchInFolderViewController: UIViewController, BackgroundBlur {
    
    @IBOutlet private weak var linkCollectionView: UICollectionView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var underLineWidthConstraint: NSLayoutConstraint!

    private let searchLinkViewModel = SearchLinkViewModel()
    
    weak var folderDetailViewController: FolderDetailViewController?
    var removeBackgroundHandler: (() -> ())?
    
    static func storyboardInstance() -> SearchInFolderViewController? {
        let storyboard = UIStoryboard(name: SearchInFolderViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareSubTitleLabel()
        prepareSearchTextField()
        prepareLinkCollectionView()
        prepareViewGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    private func bind() {
  
    }
    
    private func alertSucceedView() {
        guard let saveSucceedBottomVC = SaveSucceedBottomViewController.storyboardInstance() else { return }
        
        saveSucceedBottomVC.modalPresentationStyle = .overCurrentContext
        saveSucceedBottomVC.modalTransitionStyle = .coverVertical
        saveSucceedBottomVC.completionHandler = { [weak self] in
            self?.fadeOutBackgroundViewAnimation()
        }
        
        fadeInBackgroundViewAnimation()
        self.present(saveSucceedBottomVC, animated: true, completion: nil)
    }
    
    private func prepareSubTitleLabel() {
        // subTitleLabel.layer.addBorder([.bottom], color: UIColor.black, width: 1)
    }
    
    private func prepareLinkCollectionView() {
        linkCollectionView.register(UINib(nibName: LinkCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: LinkCell.cellIdentifier)
        linkCollectionView.dataSource = self
        linkCollectionView.delegate = self
    }
    
    private func prepareViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    private func prepareSearchTextField() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func viewTapped() {
        searchTextField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        linkCollectionView.reloadData()
    }
    
    @objc private func cellEditButtonTapped(_ sender: UIGestureRecognizer) { // edit 버튼 클릭됬을 때
//        guard let button = sender.view as? UICustomTagButton else { return }
        // guard let link = filterLinks.filter({$0.id == button.customTag}).first else { return }
        guard let editVC = EditBottomSheetViewController.storyboardInstance() else { fatalError() }
        
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .coverVertical
        editVC.isIncludeRemoveButton = true
        
        editVC.actions = ["링크 수정", "URL 공유하기", "삭제하기"] // "URL 공유하기"
        editVC.handlers = [{ [weak self] _ in // 링크 수정
            guard let self = self else { return }
            
            guard let addLinkVC = AddLinkViewController.storyboardInstance() else { return }
            
            addLinkVC.linkPresetingStyle = .edit
            // addLinkVC.link = link
            // addLinkVC.folder = folder
            addLinkVC.alertSucceedViewHandler = { [weak self] in
                guard let self = self else { return }
                self.alertSucceedView()
            }
//            addLinkVC.updateReloadHander = { [weak self] in
//                guard let self = self else { return }
//                self.folderDetailViewController?.linkCollectionView.reloadData()
//                self.linkCollectionView.reloadData()
//            }

            let selectNC = SelectNaviagitonController()
            selectNC.pushViewController(addLinkVC, animated: false)
            selectNC.modalPresentationStyle = .fullScreen
            selectNC.isNavigationBarHidden = true
            
            self.present(selectNC, animated: true, completion: nil)
            
        }, { [weak self] _ in // URL 공유하기
            guard let self = self else { return }
            
        }, { [weak self] _ in // 삭제하기
            guard let self = self else { return }
            // let indexPath = IndexPath(item: index, section: 0)
            
//            self.searchLinkViewModel.remove(target: link)
        }]
        
        editVC.completionHandler = { [weak self] in // 동작 완료하면
            guard let self = self else { return }
            self.fadeOutBackgroundViewAnimation()
        }
        
        fadeInBackgroundViewAnimation()
        present(editVC, animated: true)
    }
    
    @IBAction func sortButtonTapped() {
        guard let editVC = EditBottomSheetViewController.storyboardInstance() else { return }
        
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .coverVertical
        
        editVC.editTitle = "정렬하기"
        editVC.actions = ["이름 순", "생성 순"]
        editVC.handlers = [nil, nil]
        editVC.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.fadeOutBackgroundViewAnimation()
        }
        
        fadeInBackgroundViewAnimation()
        present(editVC, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped() {
        removeBackgroundHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeButtonTapped() {
        searchTextField.text = ""
        linkCollectionView.reloadData()
    }
}

extension SearchInFolderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let linkCell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellIdentifier, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
                
        
        return linkCell
    }
}

extension SearchInFolderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        return CGSize(width: width, height: height)
    }
}

extension SearchInFolderViewController: UICollectionViewDelegate {

}
