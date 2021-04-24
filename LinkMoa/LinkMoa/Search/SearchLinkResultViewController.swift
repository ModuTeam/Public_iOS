//
//  LinkListViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/25.
//

import UIKit
import Toast_Swift

final class SearchLinkResultViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var linkCollectionView: UICollectionView!
 
    private var viewModel: SearchLinkViewModel = SearchLinkViewModel()
    var searchedLinks: Observable<[SearchLink.Result]> = Observable([])
    var searchTarget: SearchTarget = .my
    var pageIndex: Int = 0
    var fetchMore: Bool = true
    var reloadDelegate: ReloadDelegate?
    
    var searchWord: String = "" {
        didSet {
            view.makeToastActivity(ToastPosition.center)
            linkCollectionView.setContentOffset(.zero, animated: false)
            resetSearch()
            fetchData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLinkCollectionView()
        bind()
    }
    
    static func storyboardInstance() -> SearchLinkResultViewController? {
        let storyboard = UIStoryboard(name: SearchLinkResultViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func bind() {
        viewModel.outputs.searchedLinks.bind { [weak self] results in
            guard let self = self else { return }
            self.view.hideToastActivity()
            self.searchedLinks.value.append(contentsOf: results)
            self.linkCollectionView.reloadData()
            
            if results.count < Constant.pageLimit {
                self.fetchMore = false
            } else {
                self.fetchMore = true
            }
        }

        viewModel.outputs.linkCount.bind  { [weak self] results in
            guard let self = self else { return }
            let count = "링크(\(results.toAbbreviationString))개"
            self.reloadDelegate?.reloadLinkCount(count: count)
            if results == 0 {
                self.resetSearch()
            }
        }
    }
    
    private func fetchData() {
        fetchMore = false
        viewModel.inputs.searchLink(word: searchWord, page: pageIndex, isMine: searchTarget.rawValue)
        pageIndex += 1
    }
    
    private func resetSearch() {
        pageIndex = 0
        fetchMore = true
        searchedLinks.value = []
    }
    
    private func prepareLinkCollectionView() {
        linkCollectionView.contentInset.bottom = 50
        linkCollectionView.register(UINib(nibName: LinkCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: LinkCell.cellIdentifier)
        linkCollectionView.dataSource = self
        linkCollectionView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reloadDelegate?.hideKeyboard()
        
        let contentYoffset = linkCollectionView.contentOffset.y
        let contentHeight = linkCollectionView.contentSize.height
        let scrollViewHeight = linkCollectionView.frame.size.height
        
        if contentYoffset > contentHeight - scrollViewHeight {
            if fetchMore {
                fetchData()
                DEBUG_LOG(pageIndex)
            }
        }
        
    }
}

extension SearchLinkResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedLinks.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let linkCell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.cellIdentifier, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
        if searchedLinks.value.count > 0 {
            linkCell.update(by: searchedLinks.value[indexPath.row])
        }
        
        linkCell.dotImageView.isHidden = true
        return linkCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let webVC = WebViewController.storyboardInstance() else { return }
        let links = searchedLinks.value
        let link = links[indexPath.item]
        
        //웹뷰로 링크열기
        if let url = URL(string: link.url) {
            webVC.url = url
            webVC.modalPresentationStyle = .fullScreen
            self.present(webVC, animated: true, completion: nil)
        }
    }
}

extension SearchLinkResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        return CGSize(width: width, height: height)
    }
}
