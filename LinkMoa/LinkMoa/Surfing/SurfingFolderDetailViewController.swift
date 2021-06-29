//
//  SurfingFolderDetailViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
import Toast_Swift
import RxSwift
import RxCocoa

class SurfingFolderDetailViewController: UIViewController, CustomAlert, BackgroundBlur {
    
    @IBOutlet private weak var folderTitleLabel: UILabel!
    @IBOutlet private weak var tagStackView: UIStackView!
    @IBOutlet private weak var linkCountLabel: UILabel!
    @IBOutlet private weak var likeCountLabel: UILabel!
    @IBOutlet private weak var userNameButton: UIButton!
    @IBOutlet private weak var linkCollectionView: UICollectionView!
    @IBOutlet private weak var heartImageView: UIImageView!
    @IBOutlet private weak var blueViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var likeButton: UIButton!
    
    var folderIndex: Int = 1
    
    private let tokenManager: TokenManager = TokenManager()
    
    private let viewModel: SurfingFolderDetailViewModel = SurfingFolderDetailViewModel()
    private lazy var inputs: SurfingFolderDetailViewModel.Input = .init(
        fetchFolderDetail: fetchFolderTrigger.asSignal(),
        likeAction: likeTrigger.asSignal(),
        reportAction: reportTrigger.asSignal()
    )
    private lazy var outputs: SurfingFolderDetailViewModel.Output = viewModel.transform(input: inputs)
    
    private let fetchFolderTrigger = PublishRelay<Int>()
    private let likeTrigger = PublishRelay<Int>()
    private let reportTrigger = PublishRelay<Int>()
    private let disposeBag = DisposeBag()

    weak var homeNavigationController: HomeNavigationController?
    private let shareBarButtonItem = UIBarButtonItem(image: UIImage(named: "editDot"), style: .plain, target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigation()
        prepareLinkCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFolderTrigger.accept(folderIndex)
        view.makeToastActivity(ToastPosition.center)
        homeNavigationController?.addButtonView.isHidden = true
    }
    
    private func bind() {
        outputs.folderDetail
            .drive { [weak self] results in
                guard let self = self else { return }
                self.view.hideToastActivity()
                self.updateUI(folderDetail: results)
            }.disposed(by: disposeBag)
        
        outputs.folderDetail
            .map { $0.linkList }
            .drive(linkCollectionView.rx.items(cellIdentifier: LinkCell.cellIdentifier, cellType: LinkCell.self)) {_, result, cell in
                cell.update(by: result)
            }.disposed(by: disposeBag)
  
        outputs.likeResult
            .drive { [weak self] results in
                guard let self = self else { return }
                self.updateLikeStatus(status: results.status, count: results.count)
            }.disposed(by: disposeBag)

        outputs.reportResult.drive { [weak self] results in
            guard let self = self else { return }
            if results {
                self.presentImageAlertView(type: .reportFolder)
            }
        }.disposed(by: self.disposeBag)
        
        linkCollectionView.rx.modelSelected(FolderDetail.Link.self)
            .bind(onNext: { [weak self] link in
                guard let self = self else { return }
                guard let webVC = WebViewController.storyboardInstance() else { return }
                guard let url = URL(string: link.url) else { return }
                
                if let isUsingCustomBrowser = self.tokenManager.isUsingCustomBrowser, isUsingCustomBrowser {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    webVC.url = url
                    webVC.modalPresentationStyle = .fullScreen
                    self.present(webVC, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        userNameButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                guard let surfingFolderVC = SurfingFolderViewController.storyboardInstance() else { return }
                surfingFolderVC.homeNavigationController = self.homeNavigationController
                surfingFolderVC.surfingFolerType = .users
                surfingFolderVC.userIndex = self.viewModel.dependency.userID
                surfingFolderVC.userName = self.viewModel.dependency.userName
                self.homeNavigationController?.pushViewController(surfingFolderVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        likeButton.rx.tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.likeTrigger.accept(self.folderIndex)
            }
            .disposed(by: disposeBag)
        
        shareBarButtonItem.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            guard let editVC = ButtonOptionViewController.storyboardInstance() else { return }
            
            editVC.blurVC = self
            editVC.modalPresentationStyle = .overCurrentContext
            editVC.modalTransitionStyle = .coverVertical
            editVC.isIncludeRemoveButton = true // 마지막 label red
            
            editVC.actions = ["URL 공유하기", "신고하기"]
            editVC.handlers = [ { [weak self] _ in
                guard let self = self else { return }
                guard let folderName = self.folderTitleLabel.text else { return }
                
                let shareItem = folderName + "\n\n" + self.viewModel.dependency.linkList.map { "\($0.name)\n\($0.url)\n\n" }.joined()
                
                let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
                activityController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact, .addToReadingList]
                
                self.present(activityController, animated: true, completion: nil)
            }, { [weak self] _ in
                guard let self = self else { return }
                self.presentReconfirmView(type: .reportFolder) {
                    self.reportTrigger.accept(self.folderIndex)
                }
            }
            ]
            
            self.navigationController?.present(editVC, animated: true)
        }.disposed(by: disposeBag)
        
        outputs.errorMessage
            .emit { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateUI(folderDetail: FolderDetail.Result) {
        let tags: [String] = folderDetail.hashTagList.map {$0.name}
        self.updateTagStackView(tags: tags)
        self.folderTitleLabel.text = folderDetail.name
        self.userNameButton.setTitle(folderDetail.userNickname, for: .normal)
        self.linkCountLabel.text = folderDetail.linkCount.toAbbreviationString
        self.updateLikeStatus(status: folderDetail.likeStatus, count: folderDetail.likeCount)
    }
    
    private func updateLikeStatus(status: Int, count: Int) {
        self.likeCountLabel.text = count.toAbbreviationString
        heartImageView.image = status == 1 ? UIImage(systemName: "heart.fill"):UIImage(systemName: "heart")
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
    
    private func prepareNavigation() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        blueViewHeightConstraint.constant = Device.statusBarHeight + Device.navigationBarHeight + 168
        
        shareBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        shareBarButtonItem.tintColor = .white
        navigationItem.rightBarButtonItems = [shareBarButtonItem]
    }
    
    private func prepareLinkCollectionView() {
        let nib = UINib(nibName: LinkCell.cellIdentifier, bundle: nil)
        linkCollectionView.register(nib, forCellWithReuseIdentifier: LinkCell.cellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = linkCollectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 21, left: 0, bottom: 21, right: 0)
        linkCollectionView.collectionViewLayout = layout
        
    }
}
