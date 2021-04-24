//
//  SurfingFolderDetailViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
import Toast_Swift

class SurfingFolderDetailViewController: UIViewController, CustomAlert {
    
    @IBOutlet weak var folderTitleLabel: UILabel!
    @IBOutlet weak var tagStackView: UIStackView!
    @IBOutlet weak var linkCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var linkCollectionView: UICollectionView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var blueViewHeightConstraint: NSLayoutConstraint!
    
    var folderIndex: Int = 1
    var userIndex: Int = 0
    var userName: String = ""
    weak var homeNavigationController: HomeNavigationController?
    
    private let viewModel: SurfingFolderDetailViewModel = SurfingFolderDetailViewModel()
    private let tokenManager: TokenManager = TokenManager()

    var folderDetail: Observable<FolderDetail.Result> = Observable(FolderDetail.Result())
        
    private var blurVC: BackgroundBlur? {
        return navigationController as? BackgroundBlur
    }
    
    private var homeNC: HomeNavigationController? {
        return navigationController as? HomeNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        prepareNavigationItem()
        prepareLinkCollectionView()
        prepareUserButtonGesture()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.makeToastActivity(ToastPosition.center)
        viewModel.inputs.fetchFolderDetail(folder: folderIndex)
        homeNC?.addButtonView.isHidden = true
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        blueViewHeightConstraint.constant = Device.statusBarHeight + Device.navigationBarHeight + 168
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        viewModel.inputs.likeFolder(folder: folderIndex)
    }
    
    static func storyboardInstance() -> SurfingFolderDetailViewController? {
        let storyboard = UIStoryboard(name: SurfingFolderDetailViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func bind() {
        viewModel.outputs.folderDetail.bind { [weak self] results  in
            guard let self = self else { return }
            self.view.hideToastActivity()
            self.folderDetail.value = results
            self.userIndex = results.userIndex
            self.userName = results.userNickname
            self.linkCollectionView.reloadData()
            self.updateUI(folderDetail: results)
        }
   
    }
    
    private func updateUI(folderDetail: FolderDetail.Result) {
        self.folderTitleLabel.text = folderDetail.name
        self.userNameLabel.text = folderDetail.userNickname
        self.linkCountLabel.text = folderDetail.linkCount.toAbbreviationString
        self.likeCountLabel.text = folderDetail.likeCount.toAbbreviationString
        let tags: [String] = folderDetail.hashTagList.map {$0.name}
        updateTagStackView(tags: tags)
        if folderDetail.likeStatus == 1 {
            heartImageView.image = UIImage(systemName: "heart.fill")
        } else {
            heartImageView.image = UIImage(systemName: "heart")
        }
    
    }
    
    func prepareUserButtonGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userButtonTapped))
        tapGesture.delegate = self
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(tapGesture)
    }
    
    private func updateTagStackView(tags: [String]) {
        for subView in tagStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        
        for tag in tags {
            let label = UILabel(frame: CGRect.zero)
            label.text = "#" + tag
            label.textColor = UIColor.white
            label.font = UIFont(name: "NotoSansKR-Regular", size: 14)
            
            tagStackView.addArrangedSubview(label)
        }
    }
    
    private func prepareLinkCollectionView() {
        linkCollectionView.register(UINib(nibName: LinkCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: LinkCell.cellIdentifier)
        linkCollectionView.dataSource = self
        linkCollectionView.delegate = self
    }
    

    
    private func prepareNavigationItem() {
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "editDot"), style: .plain, target: self, action: #selector(menuButtonTapped))
        shareBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        shareBarButtonItem.tintColor = .white
        
//        let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchButtonTapped))
//        searchBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
//        searchBarButtonItem.tintColor = .white
        
        navigationItem.rightBarButtonItems = [shareBarButtonItem]
    }
    
    @objc private func menuButtonTapped() {
        guard let editVC = EditBottomSheetViewController.storyboardInstance() else { return }
        
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .coverVertical
        editVC.isIncludeRemoveButton = true // 마지막 label red
        
        editVC.completionHandler = { [weak self] in
            self?.blurVC?.fadeOutBackgroundViewAnimation()
        }
        
        editVC.actions = ["URL 공유하기", "신고하기"]
        editVC.handlers = [
            { [weak self] _ in
                guard let self = self else { return }
                guard let folderName = self.folderTitleLabel.text else { return }
                
                let shareItem = folderName + "\n\n" + self.folderDetail.value.linkList.map { "\($0.name)\n\($0.url)\n\n" }.joined()
                let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
                activityController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact, .addToReadingList]
                
                self.present(activityController, animated: true, completion: nil)
            },
            { [weak self] _ in // 삭제하기
                guard let self = self else { return }
                self.blurVC?.fadeInBackgroundViewAnimation()
                self.alertReconfirmRequestView(type: .reportFolder, animationHandler: {
                    self.blurVC?.fadeOutBackgroundViewAnimation()
                },
                completeHandler: {
                    self.blurVC?.fadeOutBackgroundViewAnimation()
                    self.viewModel.inputs.reportFolder(folder: self.folderIndex, completionHandler: {
                        self.blurVC?.fadeInBackgroundViewAnimation()
                        self.alertReportSucceedView {
                            self.blurVC?.fadeOutBackgroundViewAnimation()
                        }
                    })
                })
                
            }
            
            
        ]
        
        blurVC?.fadeInBackgroundViewAnimation()
        navigationController?.present(editVC, animated: true)
    }
    
    
    
    @objc private func userButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let surfingFolderVC = SurfingFolderViewController.storyboardInstance() else { return }
        surfingFolderVC.homeNavigationController = homeNavigationController
        surfingFolderVC.userIndex = userIndex
        surfingFolderVC.surfingFolerType = .users
        surfingFolderVC.userName = userName
        homeNavigationController?.pushViewController(surfingFolderVC, animated: true)
    }
 
}

extension SurfingFolderDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SurfingFolderDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderDetail.value.linkCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let linkCell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellIdentifier, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
        
        let links = folderDetail.value.linkList
        let link = links[indexPath.item]
        
        linkCell.update(by: link)
        // linkCell.editButton.customTag = link.id
        
        return linkCell
    }
}

extension SurfingFolderDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let webVC = WebViewController.storyboardInstance() else { return }
        let links = folderDetail.value.linkList
        let link = links[indexPath.item]
                
        guard let url = URL(string: link.url) else { return }
        
        if let isUseSafari = tokenManager.isUseSafari, isUseSafari == true {            //사파리로 링크열기
            UIApplication.shared.open(url, options: [:])
        } else {
            // 웹뷰로 링크열기
            webVC.url = url
            webVC.modalPresentationStyle = .fullScreen
            present(webVC, animated: true, completion: nil)
        }
    }
}

extension SurfingFolderDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        return CGSize(width: width, height: height)
    }
}
