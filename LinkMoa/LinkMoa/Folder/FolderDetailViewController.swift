//
//  BookMarkDetailViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/07.
//

import UIKit
import Toast_Swift

final class FolderDetailViewController: UIViewController, CustomAlert {

    @IBOutlet private weak var folderTitleLabel: UILabel!
    @IBOutlet private weak var tagStackView: UIStackView!
    @IBOutlet private weak var linkCountLabel: UILabel!
    @IBOutlet private weak var lockImageView: UIImageView!
    @IBOutlet private weak var subHeaderView: UIView!
    @IBOutlet private(set) weak var linkCollectionView: UICollectionView!
    @IBOutlet weak var blueViewHeightConstraint: NSLayoutConstraint!
    
    private let tokenManager: TokenManager = TokenManager()
    private let folderDetailViewModel: FolderDetailViewModel = FolderDetailViewModel()
    private var links: [FolderDetail.Link] = []
    
    weak var homeNavigationController: HomeNavigationController?
 
    private var blurVC: BackgroundBlur? {
        return navigationController as? BackgroundBlur
    }
    
    var folderRemoveHandler: (() -> ())? // Folder 삭제됬을 때 FolderVC 에서 삭제 Alert 올릴 때 사용
    var folderIndex: Int?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func storyboardInstance() -> FolderDetailViewController? {
        let storyboard = UIStoryboard(name: FolderDetailViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareLinkCollectionView()
        prepareAddButtonGesture()
        prepareSubHeaderView()
        prepareNavigationItem()
        prepareNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.makeToastActivity(ToastPosition.center)

        if let folderIndex = folderIndex {
            folderDetailViewModel.fetchFolderDetail(folderIndex: folderIndex)
        }
    }
    
    private func bind() {
        folderDetailViewModel.outputs.links.bind { [weak self] links in
            guard let self = self else { return }
            self.links = links
            self.linkCountLabel.text = String(links.count)
            self.linkCollectionView.reloadData()
            self.view.hideToastActivity()
        }
        
        folderDetailViewModel.outputs.folderName.bind { [weak self] name in
            guard let self = self else { return }
            self.folderTitleLabel.text = name
        }
        
        folderDetailViewModel.outputs.tags.bind { [weak self] tags in
            guard let self = self else { return }
            self.updateTagStackView(tags: tags.map { $0.name })
        }
        
        folderDetailViewModel.outputs.isShared.bind { [weak self] isShared in
            guard let self = self else { return }
            self.lockImageView.isHidden = isShared ? true : false
        }
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
    
    private func prepareAddButtonGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
        tapGesture.delegate = self
        homeNavigationController?.addButtonView.addGestureRecognizer(tapGesture)
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        blueViewHeightConstraint.constant = Device.statusBarHeight + Device.navigationBarHeight + 168
    }
    
    private func prepareNavigationItem() {
        let editBarButtonItem = UIBarButtonItem(image: UIImage(named: "editDot"), style: .plain, target: self, action: #selector(folderEditButtonTapped))
        editBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        editBarButtonItem.tintColor = .white
        
        // let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchButtonTapped))
        // searchBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        // searchBarButtonItem.tintColor = .white
        
        navigationItem.rightBarButtonItem = editBarButtonItem
    }
    
    private func prepareSubHeaderView() {
        subHeaderView.layer.masksToBounds = true
        subHeaderView.layer.cornerRadius = 10
    }
    
    private func discountLinkCountLabel() {
        guard let countString = linkCountLabel.text, let count = Int(countString) else { return }
        
        linkCountLabel.text = "\(count - 1)"
    }
    
    @objc private func folderEditButtonTapped() {
        guard let editVC = EditBottomSheetViewController.storyboardInstance() else { return }
        guard let folderIndex = folderIndex, let folderName = self.folderTitleLabel.text else { return }
        
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .coverVertical
        editVC.isIncludeRemoveButton = true // 마지막 label red

        editVC.completionHandler = { [weak self] in
            self?.blurVC?.fadeOutBackgroundViewAnimation()
        }
        
        editVC.actions = ["폴더 수정", "URL 공유하기", "삭제하기"]
        editVC.handlers = [{ [weak self] _ in // 폴더 수정 클릭
            guard let self = self else { return }
            guard let editFolderVC = AddFolderViewController.storyboardInstance() else { return }
            guard let folderIndex = self.folderIndex else { return }
                        
            editFolderVC.folderPresentingType = .edit
            editFolderVC.modalPresentationStyle = .fullScreen
            
            editFolderVC.folderIndex = folderIndex // 폴더 인덱스
            editFolderVC.folder = self.folderDetailViewModel.outputs.folderDetail.value
            editFolderVC.alertSucceedViewHandler = {
                self.blurVC?.fadeInBackgroundViewAnimation()
                self.alertSucceedView(completeHandler: { self.blurVC?.fadeOutBackgroundViewAnimation() })
            }
            
            let addFolderNC = AddFolderNavigationController(rootViewController: editFolderVC)
            addFolderNC.modalPresentationStyle = .fullScreen
            
            self.present(addFolderNC, animated: true, completion: nil)
        }, { [weak self] _ in
            guard let self = self else { return }
            guard let folderName = self.folderTitleLabel.text else { return }
            
            let shareItem = folderName + "\n\n" + self.links.map { "\($0.name)\n\($0.url)\n\n" }.joined()
            let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
            activityController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact, .addToReadingList]

            self.present(activityController, animated: true, completion: nil)
        }, { [weak self] _ in // 삭제하기
            guard let self = self else { return }
            
            self.blurVC?.fadeInBackgroundViewAnimation()
            self.alertRemoveRequestView(folderName: folderName,
                                        completeHandler: {
                                            self.blurVC?.fadeOutBackgroundViewAnimation()
                                        },
                                        removeHandler: {
                                            self.folderDetailViewModel.removeFolder(folderIndex: folderIndex, completionHandler: { result in
                                                switch result {
                                                case .success(let response):
                                                    if response.isSuccess {
                                                        self.navigationController?.popViewController(animated: true)
                                                        self.folderRemoveHandler?()
                                                    } else {
                                                        print("서버 에러")
                                                    }
                                                case .failure(let error):
                                                    self.blurVC?.fadeInBackgroundViewAnimation()
                                                    print(error)
                                                }
                                            })
                                        })
        }]
        
        blurVC?.fadeInBackgroundViewAnimation()
        navigationController?.present(editVC, animated: true)
    }
    
    @objc private func addButtonTapped() {
        guard let _ = homeNavigationController?.topViewController as? FolderDetailViewController else { return }
        guard let addLinkVC = AddLinkViewController.storyboardInstance() else { return }
        guard let folderName = self.folderTitleLabel.text else { return }
        guard let folderIndex = folderIndex else { return }
        
        addLinkVC.destinationFolderIndex = folderIndex
        addLinkVC.destinationFolderName = folderName
        
        addLinkVC.alertSucceedViewHandler = { [weak self] in
            guard let self = self else { return }
            self.blurVC?.fadeInBackgroundViewAnimation()
            self.alertSucceedView { self.blurVC?.fadeOutBackgroundViewAnimation() }
        }
        
        let selectNC = SelectNaviagitonController()
        selectNC.pushViewController(addLinkVC, animated: false)
        selectNC.modalPresentationStyle = .fullScreen
        selectNC.isNavigationBarHidden = true
        
        present(selectNC, animated: true, completion: nil)
    }
    
    @objc private func cellEditButtonTapped(_ sender: UIGestureRecognizer) { // edit 버튼 클릭됬을 때
        guard let button = sender.view as? UICustomTagButton else { return }
        guard let link = links.filter({ $0.index == button.customTag }).first else { return }
        guard let index = links.firstIndex(of: link) else { return }
        guard let editVC = EditBottomSheetViewController.storyboardInstance() else { return }
        
        editVC.modalPresentationStyle = .overCurrentContext
        editVC.modalTransitionStyle = .coverVertical
        editVC.isIncludeRemoveButton = true
        
        editVC.actions = ["링크 수정", "URL 공유하기", "삭제하기"] // "URL 공유하기"
        editVC.handlers = [{ [weak self] _ in // 링크 수정
            guard let self = self else { return }
            guard let addLinkVC = AddLinkViewController.storyboardInstance() else { return }
            guard let folderIndex = self.folderIndex, let folderName = self.folderTitleLabel.text else { return }
            
            addLinkVC.linkPresetingStyle = .edit
            addLinkVC.link = link
            addLinkVC.destinationFolderName = folderName
            addLinkVC.destinationFolderIndex = folderIndex
            
            addLinkVC.alertSucceedViewHandler = { [weak self] in
                guard let self = self else { return }
                
                self.blurVC?.fadeInBackgroundViewAnimation()
                self.alertSucceedView(completeHandler: { self.blurVC?.fadeOutBackgroundViewAnimation() })
            }
            
            let selectNC = SelectNaviagitonController()
            selectNC.pushViewController(addLinkVC, animated: false)
            selectNC.modalPresentationStyle = .fullScreen
            selectNC.isNavigationBarHidden = true
            
            self.present(selectNC, animated: true, completion: nil)
            
        }, { [weak self] _ in // URL 공유하기
            guard let self = self else { return }
            
            let activityController = UIActivityViewController(activityItems: ["\(link.name)\n\(link.url)"], applicationActivities: nil)
            activityController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact, .addToReadingList]
            
            self.present(activityController, animated: true, completion: nil)
        }, { [weak self] _ in // 삭제하기
            guard let self = self else { return }
            let indexPath = IndexPath(item: index, section: 0)
            
            self.folderDetailViewModel.deleteLink(link: link.index, completionHandler: { result in
                switch result {
                case .success(let linkResponse):
                    if linkResponse.isSuccess {
                        self.links.remove(at: index)
                        self.linkCollectionView.deleteItems(at: [indexPath])
                        self.discountLinkCountLabel()
                        
                        self.blurVC?.fadeInBackgroundViewAnimation()
                        self.alertRemoveSucceedView(completeHandler: { self.blurVC?.fadeOutBackgroundViewAnimation() })
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }]
        
        editVC.completionHandler = { [weak self] in // 동작 완료하면
            self?.blurVC?.fadeOutBackgroundViewAnimation()
        }
        
        blurVC?.fadeInBackgroundViewAnimation()
        present(editVC, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        guard let searchLinkVC = SearchInFolderViewController.storyboardInstance() else { return }
        
        searchLinkVC.modalTransitionStyle = .crossDissolve
        searchLinkVC.modalPresentationStyle = .overCurrentContext
        searchLinkVC.folderDetailViewController = self
        homeNavigationController?.present(searchLinkVC, animated: true, completion: nil)
    }
    
    @objc private func willEnterForeground() {
        view.makeToastActivity(ToastPosition.center)

        if let folderIndex = folderIndex {
            folderDetailViewModel.fetchFolderDetail(folderIndex: folderIndex)
        }
    }
}

extension FolderDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FolderDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let linkCell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellIdentifier, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellEditButtonTapped(_:)))
        let link = links[indexPath.item]
        
        linkCell.update(by: link)
        linkCell.editButton.addGestureRecognizer(tapGesture)
        linkCell.editButton.customTag = link.index
        
        return linkCell
    }
}

extension FolderDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let webVC = WebViewController.storyboardInstance() else { return }
        
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

extension FolderDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        return CGSize(width: width, height: height)
    }
}
