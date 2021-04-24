//
//  SavedFolderViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
enum SurfingFolderType {
    case topTen
    case liked
    case users
}

class SurfingFolderViewController: UIViewController {
    
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    var surfingFolerType: SurfingFolderType = .topTen
    weak var homeNavigationController: HomeNavigationController?
    
    private let viewModel: SurfingFolderViewModel = SurfingFolderViewModel()
    
    var topTenFolders: Observable<[TopTenFolder.Result]> = Observable([])
    var likedFolders: Observable<[LikedFolder.Result]> = Observable([])
    var usersFolders: Observable<[UsersFolder.Result]> = Observable([])
    var pageIndex: Int = 0
    var userIndex: Int = 0
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFolderCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareNavigationBar()
        prepareHeader()
        fetchData()
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        
    }
    
    func bind() {
        switch surfingFolerType {
        case .topTen:
            viewModel.outputs.topTenFolders.bind { [weak self] results in
                guard let self = self else { return }
                self.topTenFolders.value = results
                self.folderCollectionView.reloadData()
            }
        case .liked :
            viewModel.outputs.likedFolders.bind { [weak self] results in
                guard let self = self else { return }
                self.likedFolders.value = results
                self.countLabel.text = "\(results.count.toAbbreviationString)개"
                self.folderCollectionView.reloadData()
            }
        case .users:
            viewModel.outputs.usersFolders.bind { [weak self] results in
                guard let self = self else { return }
                self.usersFolders.value = results
                self.countLabel.text = "\(results.count.toAbbreviationString)개"
                self.folderCollectionView.reloadData()
            }
        }
    }
    
    private func fetchData() {
        switch surfingFolerType {
        case .topTen:
            viewModel.inputs.fetchTopTenFolder()
        case .liked :
            viewModel.inputs.fetchLikedFolders(word: nil, page: pageIndex)
        case .users:
            viewModel.inputs.fetchUsersFolders(user: userIndex, page: pageIndex)        }
    }
    
    static func storyboardInstance() -> SurfingFolderViewController? {
        let storyboard = UIStoryboard(name: SurfingFolderViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    


    
    private func prepareHeader() {
        switch surfingFolerType {
        case .topTen:
            titleLabel.text = "TOP 10 링크달"
            countLabel.isHidden = true
        case .liked:
            titleLabel.text = "찜한 링크달"
        case .users:
            titleLabel.text = userName
        }
        
    }

    private func prepareFolderCollectionView() {
        folderCollectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 50, right: 16)
        let nib: UINib = UINib(nibName: FolderCell.cellIdentifier, bundle: nil)
        folderCollectionView.register(nib, forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        
        folderCollectionView.dataSource = self
        folderCollectionView.delegate = self
    }
}


extension SurfingFolderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch surfingFolerType {
        case .topTen:
            return topTenFolders.value.count
        case .liked :
            return likedFolders.value.count
        case .users:
            return usersFolders.value.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }
        
        switch surfingFolerType {
        case .topTen:
            folderCell.update(by: topTenFolders.value[indexPath.row])
        case .liked:
            folderCell.update(by: likedFolders.value[indexPath.row])
        case .users:
            folderCell.update(by: usersFolders.value[indexPath.row])
        }
        return folderCell
    }
    
}

extension SurfingFolderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let folderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
        folderDetailVC.homeNavigationController = homeNavigationController
        switch surfingFolerType {
        case .topTen:
            folderDetailVC.folderIndex = topTenFolders.value[indexPath.row].folderIndex
        case .liked :
            folderDetailVC.folderIndex = likedFolders.value[indexPath.row].folderIndex
        case .users:
            folderDetailVC.folderIndex = usersFolders.value[indexPath.row].index
        }
        homeNavigationController?.pushViewController(folderDetailVC, animated: true)
    }
}

extension SurfingFolderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.frame.width - 47) / 2
        let height: CGFloat = 214
        return CGSize(width: width, height: height)
    }
    
}
