//
//  BookmarkAddFolderViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/04.
//

import UIKit
import Toast_Swift

enum FolderPresentingType {
    case add
    case edit
}
    
final class AddFolderViewController: UIViewController {

    @IBOutlet private weak var folderNameTextField: UITextField! // tag 1
    @IBOutlet private weak var tagNameTextField: UITextField! // tag 2
    
    @IBOutlet private weak var tagCollectionView: UICollectionView!
    @IBOutlet private weak var publicOptionButtonView: UIView!
    @IBOutlet private weak var publicTitleLabel: UILabel!

    @IBOutlet private weak var privateOptionButtonView: UIView!
    @IBOutlet private weak var privateTitleLabel: UILabel!
    
    @IBOutlet private weak var nextButtonView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tagNotificationView: UIView!
    
    private let addFolderViewModel: AddFolderViewModel = AddFolderViewModel()
    private let link = LinkPresentaionService()
    
    private var tags: [String] = [] {
        didSet {
            if tags.count == 0 {
                tagNotificationView.isHidden = false
            } else {
                tagNotificationView.isHidden = true
            }
            
            tagCollectionView.reloadData()
        }
    }
    
    private var isShared: Bool = false {
        didSet {
            if isShared == false { // private
                privateOptionButtonView.backgroundColor = .linkMoaDarkBlueColor
                privateTitleLabel.textColor = UIColor.white
                
                publicOptionButtonView.backgroundColor = .linkMoaOptionBackgroundColor
                publicTitleLabel.textColor = .linkMoaOptionTextColor
            } else { // public
                privateOptionButtonView.backgroundColor = .linkMoaOptionBackgroundColor
                privateTitleLabel.textColor = .linkMoaOptionTextColor
                
                publicOptionButtonView.backgroundColor = .linkMoaDarkBlueColor
                publicTitleLabel.textColor = UIColor.white
            }
        }
    }
    
    var folderPresentingType: FolderPresentingType = .add
    
    // edit ???????????? ??????
    var folder: FolderDetail.Result?
    var folderIndex: Int?
    
    // add ???????????? ?????? -> ???????????? ?????? ??????????????? ??? ?????? ???????????? ????????????
    var categoryName: String?
    var categoryNumber: Int?
    var detailCategoryName: String?
    var detailCategoryNumber: Int?
    
    lazy var saveCategory: (String, Int) -> Void = { [weak self] name, number in
        guard let self = self else { return }
        self.categoryName = name
        self.categoryNumber = number
    }
    
    lazy var saveDetailCategory: (String, Int) -> Void = { [weak self] name, number in
        guard let self = self else { return }
        self.detailCategoryName = name
        self.detailCategoryNumber = number
    }
    
    // var editCompletionHandler: (() -> ())? // FolderVC ????????? ??? ???
    var alertSucceedViewHandler: (() -> Void)? // PresetingVC ?????? Alert ????????? ???

    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
        prepareNextButtonView()
        prepareOptionButtons()
        prepareTagCollectionView()
        prepareTagNameTextField()
        prepareFolderNameTextField()
        prepareTagNotificationView()
        prepareViewGesture()
    }
    
    private func update() {
        guard let folder = folder else { return }
        
        isShared = folder.type == "private" ? false : true
        
        switch folderPresentingType {
        case .add:
            break
        case .edit:
            titleLabel.text = "?????? ??????"
            folderNameTextField.text = folder.name
            tags = folder.hashTagList.map { $0.name }
        }
    }
    
    private func prepareTagNotificationView() {
        tagNotificationView.layer.masksToBounds = true
        tagNotificationView.layer.cornerRadius = 16
    }
    
    private func prepareNextButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonTapped))
        nextButtonView.addGestureRecognizer(tapGesture)
        nextButtonView.isUserInteractionEnabled = true
        
        nextButtonView.layer.masksToBounds = true
        nextButtonView.layer.cornerRadius = 8
    }
    
    private func prepareOptionButtons() {
        let publicTapGesture = UITapGestureRecognizer(target: self, action: #selector(publicOptionTapped))
        publicOptionButtonView.addGestureRecognizer(publicTapGesture)
        publicOptionButtonView.isUserInteractionEnabled = true
        
        publicOptionButtonView.layer.masksToBounds = true
        publicOptionButtonView.layer.cornerRadius = 8
        
        let privateTapGesture = UITapGestureRecognizer(target: self, action: #selector(privateOptionTapped))
        privateOptionButtonView.addGestureRecognizer(privateTapGesture)
        privateOptionButtonView.isUserInteractionEnabled = true
        
        privateOptionButtonView.layer.masksToBounds = true
        privateOptionButtonView.layer.cornerRadius = 8
    }
    
    private func prepareTagCollectionView() {
        tagCollectionView.register(UINib(nibName: TagCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: TagCell.cellIdentifier)
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
    }
    
    private func prepareFolderNameTextField() {
        folderNameTextField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: folderNameTextField.frame.height))
        folderNameTextField.leftView = paddingView
        folderNameTextField.leftViewMode = .always
        
        folderNameTextField.attributedPlaceholder = NSAttributedString(string: "UXUI ?????????", attributes: [
            .foregroundColor: UIColor.linkMoaPlaceholderColor,
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        folderNameTextField.layer.masksToBounds = true
        folderNameTextField.layer.cornerRadius = 8
    }
    
    private func prepareTagNameTextField() {
        tagNameTextField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: folderNameTextField.frame.height))
        tagNameTextField.leftView = paddingView
        tagNameTextField.leftViewMode = .always
        
        tagNameTextField.attributedPlaceholder = NSAttributedString(string: "?????? ?????? ??????", attributes: [
            .foregroundColor: UIColor.linkMoaPlaceholderColor,
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        tagNameTextField.layer.masksToBounds = true
        tagNameTextField.layer.cornerRadius = 8
    }
    
    private func prepareViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func publicOptionTapped() {
        isShared = true
    }
    
    @objc private func privateOptionTapped() {
        isShared = false
    }
    
    @objc private func nextButtonTapped() {
        guard let name = folderNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard !name.isEmpty else {
            view.makeToast("?????? ????????? ??????????????????.", position: .top)
            return
        }
        let nameLimit = 18
        guard name.count <= nameLimit else {
            view.makeToast("?????? ????????? \(nameLimit)?????? ?????? ??? ????????????.", position: .top)
            return
        }
        
        guard let addFolderCategoryVC = AddFolderCategoryViewController.storyboardInstance() else { return }
        
        // ?????? VC??? ????????? ??????
        switch folderPresentingType {
        case .add:
            if let name = categoryName, let number = categoryNumber {
                addFolderCategoryVC.categoryName = name
                addFolderCategoryVC.categoryNumber = number
            }
            
            if let detailName = detailCategoryName, let detailNumber = detailCategoryNumber {
                addFolderCategoryVC.detailCategoryName = detailName
                addFolderCategoryVC.detailCategoryNumber = detailNumber
            }
            
            addFolderCategoryVC.saveCategory = saveCategory
            addFolderCategoryVC.saveDetailCategory = saveDetailCategory
        case .edit:
            addFolderCategoryVC.folder = folder
        }
        
        addFolderCategoryVC.folderName = name
        addFolderCategoryVC.tags = tags
        addFolderCategoryVC.isShared = isShared
        
        addFolderCategoryVC.folderPresentingType = folderPresentingType
        addFolderCategoryVC.alertSucceedViewHandler = alertSucceedViewHandler
        
        navigationController?.pushViewController(addFolderCategoryVC, animated: true)
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension AddFolderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.cellIdentifier, for: indexPath) as? TagCell else { return UICollectionViewCell() }
        
        let tagName = tags[indexPath.item]
        tagCell.update(by: tagName)
        
        return tagCell
    }
}

extension AddFolderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = tags[indexPath.item]
        tags = tags.filter { $0 != tag }
    }
}

extension AddFolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            print("")
            textField.resignFirstResponder()
            tagNameTextField.becomeFirstResponder()
        case 2:
            if let tag = textField.text, !tag.isEmpty {
                if tags.firstIndex(of: tag) != nil { // ?????? ?????? ??????
                    self.view.makeToast("????????? ???????????? ???????????????.", position: .top)
                    print("????????? ???????????? ???????????????.")
                    return true
                }
                
                if tag.count > 10 {
                    view.makeToast("????????? 10?????? ?????? ??? ????????????.", position: .top)
                    print("????????? 10?????? ?????? ??? ????????????.")
                    return true
                }
                
                if tags.count >= 3 {
                    view.makeToast("????????? 3?????? ????????? ??? ????????????.", position: .top)
                    print("????????? 3?????? ????????? ??? ????????????.")
                    return true
                }
                
                tags += [tag]
                textField.text = ""
            }
        default:
            break
        }
        
        return true
    }
}
