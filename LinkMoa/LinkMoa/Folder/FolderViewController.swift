//
//  LinkViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/01/31.
//

import UIKit
import Toast_Swift

final class FolderViewController: UIViewController, CustomAlert {
    
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    @IBOutlet private weak var notificationStackView: UIStackView!
    
    private let folderViewModel: FolderViewModel = FolderViewModel()
    private var folders: [FolderList.Result] = []
    
    private var folderHeaderView: FolderHeaderView?
    weak var homeNavigationController: HomeNavigationController?
    
    private let refreshControl = UIRefreshControl()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFolderCollectionView()
        prepareAddButtonGesture()
        prepareRefreshControler()
        bind()
        view.makeToastActivity(ToastPosition.center)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        folderViewModel.inputs.fetchFolders(completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeNavigationController?.addButtonView.isHidden = false
    }
    
    private func bind() {
        folderViewModel.outputs.folders.bind { [weak self] results in
            guard let self = self else { return }
            
            self.folders = results
            self.notificationStackView.isHidden = results.count == 0 ? false : true
            self.folderHeaderView?.update(by: results.count)
            self.folderCollectionView.reloadData()
            self.view.hideToastActivity()
        }
    }
    
    private func prepareRefreshControler() {
        folderCollectionView.refreshControl = refreshControl
        refreshControl.bounds.origin.x = 15
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    private func prepareFolderCollectionView() {
        folderCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 50, right: 15)
        
        folderCollectionView.register(UINib(nibName: FolderCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        folderCollectionView.register(UINib(nibName: FolderHeaderView.reuseableViewIndetifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FolderHeaderView.reuseableViewIndetifier)
        
        folderCollectionView.dataSource = self
        folderCollectionView.delegate = self
    }
    
    private func prepareAddButtonGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addButtonTapped))
        tapGesture.delegate = self
        homeNavigationController?.addButtonView.addGestureRecognizer(tapGesture)
    }
    
    private func presentAddFolder() { // 폴더 추가 페이지 - 플로팅 버튼
        guard let addFolderVC = AddFolderViewController.storyboardInstance() else { fatalError() }
        addFolderVC.alertSucceedViewHandler = { [weak self] in
            guard let self = self else { return }
            self.presentImageAlertView()
        }
        
        let addFolderNC = AddFolderNavigationController(rootViewController: addFolderVC)
        addFolderNC.modalPresentationStyle = .fullScreen
        present(addFolderNC, animated: true, completion: nil)
    }
    
    private func presentAddLink() { // 링크 추가 페이지 - 플로팅 버튼
        guard let addLinkVC = AddLinkViewController.storyboardInstance() else { return }
        
        addLinkVC.alertSucceedViewHandler = { [weak self] in
            guard let self = self else { return }
            self.presentImageAlertView()
        }
        
        let selectNC = SelectNaviagitonController()
        selectNC.pushViewController(addLinkVC, animated: false)
        selectNC.modalPresentationStyle = .fullScreen
        selectNC.isNavigationBarHidden = true
        
        present(selectNC, animated: true, completion: nil)
    }
    
    @objc private func willEnterForeground() {
        folderViewModel.inputs.fetchFolders(completion: nil)
    }
    
    @objc private func headerSortButtonTapped() {
        guard let _ = homeNavigationController?.topViewController as? HomeViewController else { return }
        guard let buttonOptionVC = ButtonOptionViewController.storyboardInstance() else { fatalError() }
        
        buttonOptionVC.blurVC = self
        buttonOptionVC.modalPresentationStyle = .overCurrentContext
        buttonOptionVC.modalTransitionStyle = .coverVertical
        
        buttonOptionVC.editTitle = "정렬하기"
        buttonOptionVC.actions = ["이름 순", "생성 순", "최신 순"]
        buttonOptionVC.handlers = [ { [weak self] _ in
            guard let self = self else { return }
            self.view.makeToastActivity(ToastPosition.center)
            self.folderHeaderView?.sortLabel.text = "이름 순"
            self.folderViewModel.folderFetchType = .name
            self.folderViewModel.inputs.fetchFolders(completion: nil)
        }, { [weak self] _ in
            guard let self = self else { return }
            self.view.makeToastActivity(ToastPosition.center)
            self.folderHeaderView?.sortLabel.text = "생성 순"
            self.folderViewModel.folderFetchType = .old
            self.folderViewModel.inputs.fetchFolders(completion: nil)
        }, { [weak self] _ in
            guard let self = self else { return }
            self.view.makeToastActivity(ToastPosition.center)
            self.folderHeaderView?.sortLabel.text = "최신 순"
            self.folderViewModel.folderFetchType = .current
            self.folderViewModel.inputs.fetchFolders(completion: nil)
        }]
        
        present(buttonOptionVC, animated: true)
    }
    
    @objc private func addButtonTapped() { // 플로팅 버튼 클릭됬을 떄
        guard let _ = homeNavigationController?.topViewController as? HomeViewController else { return }
        guard let buttonOptionVC = ButtonOptionViewController.storyboardInstance() else { fatalError() }
        buttonOptionVC.blurVC = self
        buttonOptionVC.editTitle = "추가하기"
        buttonOptionVC.modalPresentationStyle = .overCurrentContext
        buttonOptionVC.modalTransitionStyle = .coverVertical
        
        buttonOptionVC.actions = ["폴더 추가", "링크 추가"]
        buttonOptionVC.handlers = [ { _ in
            self.presentAddFolder()
        }, { _ in
            self.presentAddLink()
        }]
        
        present(buttonOptionVC, animated: true)
    }
    
    @objc private func cellEditButtonTapped(_ sender: UIGestureRecognizer) { // edit 버튼 클릭됬을 때
        guard let button = sender.view as? UICustomTagButton else { return }
        guard let folder = folders.filter({$0.index == button.customTag}).first else { return }
        guard let index = folders.firstIndex(of: folder) else { return }
        
        guard let buttonOptionVC = ButtonOptionViewController.storyboardInstance() else { fatalError() }
        
        buttonOptionVC.blurVC = self
        buttonOptionVC.modalPresentationStyle = .overCurrentContext
        buttonOptionVC.modalTransitionStyle = .coverVertical
        buttonOptionVC.isIncludeRemoveButton = true
        
        buttonOptionVC.actions = ["폴더 수정", "URL 공유하기", "삭제하기"] // "URL 공유하기"
        buttonOptionVC.handlers = [ { [weak self] _ in // 폴더 수정 클릭
            guard let self = self else { return }
            guard let editFolderVC = AddFolderViewController.storyboardInstance() else { return }
            
            self.folderViewModel.inputs.fetchFolderDetail(folderIndex: folder.index, completionHandler: { result in
                switch result {
                case .success(let folderDetail):
                    if let result = folderDetail.result, folderDetail.isSuccess {
                        editFolderVC.folderPresentingType = .edit
                        editFolderVC.folderIndex = folder.index // 폴더 인덱스
                        editFolderVC.folder = result // 폴더 상세
                        editFolderVC.alertSucceedViewHandler = {
                            self.presentImageAlertView()
                        }
                        
                        let addFolderNC = AddFolderNavigationController(rootViewController: editFolderVC)
                        addFolderNC.modalPresentationStyle = .fullScreen
                        self.present(addFolderNC, animated: true, completion: nil)
                    } else {
                        print("서버 에러 발생")
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }, { [weak self] _ in
            guard let self = self else { return }
            
            self.folderViewModel.inputs.fetchFolderDetail(folderIndex: folder.index, completionHandler: { result in
                switch result {
                case .success(let folderDetail):
                    if let result = folderDetail.result, folderDetail.isSuccess {
                        
                        let shareItem = result.name + "\n\n" + result.linkList.map { "\($0.name)\n\($0.url)\n\n" }.joined()
                        let activityController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
                        activityController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact, .addToReadingList]
                        
                        self.present(activityController, animated: true, completion: nil)
                    } else {
                        print("서버 에러 발생")
                    }
                case .failure(let error):
                    print(error)
                }
                
            })
        }, { [weak self] _ in // 삭제하기 클릭
            guard let self = self else { return }
            
            self.presentTextRequestView(name: folder.name) { _ in
                self.folderViewModel.removeFolder(folderIndex: folder.index) { result in
                    switch result {
                    case .success(let response):
                        if response.isSuccess {
                            self.presentImageAlertView(type: .removeFolder)
                            
                            let indexPath = IndexPath(item: index, section: 0)
                            self.folders.remove(at: index)
                            self.folderCollectionView.deleteItems(at: [indexPath])
                            self.folderCollectionView.collectionViewLayout.invalidateLayout()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }]
        
        present(buttonOptionVC, animated: true)
    }
    
    @objc private func viewTapped() {
        guard let searchFolderNC = SearchMainNavigationController.storyboardInstance() else { return }
        
        searchFolderNC.modalTransitionStyle = .crossDissolve
        searchFolderNC.modalPresentationStyle = .fullScreen
        searchFolderNC.searchTarget = .my
        present(searchFolderNC, animated: true, completion: nil)
    }
    
    @objc private func pullToRefresh() {
        
        folderViewModel.inputs.fetchFolders { [weak self] in
            guard let self = self else { return }
            
            print("refresh")
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
}

extension FolderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellEditButtonTapped(_:)))
        let folder = folders[indexPath.item]
        
        folderCell.gradientLayer.isHidden = false // 테스트로 추가
        folderCell.update(by: folder)
        folderCell.editButton.addGestureRecognizer(tapGesture)
        folderCell.editButton.customTag = folder.index
        
        return folderCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FolderHeaderView.reuseableViewIndetifier, for: indexPath) as? FolderHeaderView else { fatalError() }
            
            folderHeaderView = headerView
            
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
            headerView.searchView.addGestureRecognizer(tapGesture2)
            headerView.searchView.isUserInteractionEnabled = true
                 
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerSortButtonTapped))
            
            headerView.sortButton.addGestureRecognizer(tapGesture)
            headerView.sortButton.isUserInteractionEnabled = true
            
            headerView.update(by: folders.count)
            return headerView
        default:
            fatalError()
        }
    }
}

extension FolderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let folderDetailVC = FolderDetailViewController.storyboardInstance() else { fatalError() }
        
        let folder = folders[indexPath.item]
        folderDetailVC.homeNavigationController = homeNavigationController
        folderDetailVC.folderRemoveHandler = { [weak self] in
            guard let self = self else { return }
            self.presentImageAlertView(type: .removeFolder)
        }
        
        folderDetailVC.folderIndex = folder.index
        self.homeNavigationController?.pushViewController(folderDetailVC, animated: true)
    }
}

extension FolderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.frame.width - 47) / 2
        let height: CGFloat = 214
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = 160
        
        return CGSize(width: width, height: height)
    }
    
}

extension FolderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
