//
//  SearchFolderResultViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/25.
//

import UIKit
import Toast_Swift

final class SearchFolderResultViewController: UIViewController {

    @IBOutlet var folderCollectionView: UICollectionView!

    private var viewModel: SearchFolderViewModel = SearchFolderViewModel()
    var searchedFolders: Observable<[SearchFolder.Result]> = Observable([])
    var searchTarget: SearchTarget = .my
    var pageIndex: Int = 0
    var fetchMore: Bool = true
    var reloadDelegate: ReloadDelegate?

    var searchWord: String = "" {
        didSet {
            view.makeToastActivity(ToastPosition.center)
            folderCollectionView.setContentOffset(.init(x: -15, y: -24), animated: false)
            resetSearch()
            fetchData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFolderCollectionView()
        bind()
    }
    
    static func storyboardInstance() -> SearchFolderResultViewController? {
        let storyboard = UIStoryboard(name: SearchFolderResultViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func bind() {
        viewModel.outputs.searchedFolders.bind { [weak self] results in
            guard let self = self else { return }
            self.view.hideToastActivity()
            self.searchedFolders.value.append(contentsOf: results)
            self.folderCollectionView.reloadData()
            
            if results.count < Constant.pageLimit {
                self.fetchMore = false
            } else {
                self.fetchMore = true
            }
        }

        viewModel.outputs.folderCount.bind  { [weak self] results in
            guard let self = self else { return }
            let count = "폴더(\(results.toAbbreviationString))개"
            self.reloadDelegate?.reloadFolderCount(count: count)
            if results == 0 {
                self.resetSearch()
            }
        }
    }
    
    private func fetchData() {
        fetchMore = false
        viewModel.inputs.searchFolder(word: searchWord, page: pageIndex, isMine: searchTarget.rawValue)
        pageIndex += 1
        
    }
    
    private func resetSearch() {
        pageIndex = 0
        fetchMore = true
        searchedFolders.value = []
    }

    private func prepareFolderCollectionView() {
        folderCollectionView.contentInset = UIEdgeInsets(top: 24, left: 15, bottom: 50, right: 15)
        folderCollectionView.register(UINib(nibName: FolderCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: FolderCell.cellIdentifier)
    
        folderCollectionView.dataSource = self
        folderCollectionView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reloadDelegate?.hideKeyboard()
        
        let contentYoffset = folderCollectionView.contentOffset.y
        let contentHeight = folderCollectionView.contentSize.height
        let scrollViewHeight = folderCollectionView.frame.height
        
        if contentYoffset > contentHeight - scrollViewHeight {
            if fetchMore {
                fetchData()
                DEBUG_LOG(pageIndex)
            }
        }
        
    }
}

extension SearchFolderResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedFolders.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }

        if searchedFolders.value.count > 0 {
            folderCell.update(by: searchedFolders.value[indexPath.item])
        }

        return folderCell
    }
}

extension SearchFolderResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch searchTarget {
        case .my:
            guard let folderDetailVC = FolderDetailViewController.storyboardInstance() else { fatalError() }
            let folder = searchedFolders.value[indexPath.item]
            
            folderDetailVC.folderIndex = folder.folderIndex
            
            navigationController?.pushViewController(folderDetailVC, animated: true)
        case .surf:
            guard let folderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
            folderDetailVC.folderIndex = searchedFolders.value[indexPath.item].folderIndex
            navigationController?.pushViewController(folderDetailVC, animated: true)
        }   
    }
    

}

extension SearchFolderResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.frame.width - 47) / 2
        let height: CGFloat = 214
        
        return CGSize(width: width, height: height)
    }
}
