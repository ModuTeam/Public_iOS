//
//  CategoryDetailViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
import Toast_Swift

class CategoryDetailViewController: UIViewController {
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var blueViewHeightConstraint: NSLayoutConstraint!
    
    weak var homeNavigationController: HomeNavigationController?
    private let viewModel: CategoryViewModel = CategoryViewModel()
    private var categoryDetailFolders: Observable<[CategoryDetailFolder.FolderList]> = Observable([])
    private var categories: Observable<[CategoryInfo.DetailCategoryList]> = Observable([])
    
    private let categoryMain: [String] = ["개발", "디자인", "마케팅/광고", "기획", "기타"]
    
    private let refreshControl = UIRefreshControl()
    
    var mainIndex: Int = 0
    var subIndex: Int = 0
    var lastFolderIndex: Int = 0
    var fetchMore: Bool = true
    var lastContentOffset: CGFloat = 0
    var tagDynamicHeight: CGFloat = 0
    var containerViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        prepareNavigationBar()
        prepareFolderCollectionView()
        prepareRefreshControler()
        prepareTagCollectionView()
        viewModel.inputs.fetchCategories(at: mainIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareFetchData()        
        fetchData()
        updateUI()
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        blueViewHeightConstraint.constant = Device.statusBarHeight + Device.navigationBarHeight + 44
    }
    
    static func storyboardInstance() -> CategoryDetailViewController? {
        let storyboard = UIStoryboard(name: CategoryDetailViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func bind() {
        viewModel.outputs.categories.bind { [weak self] results in
            guard let self = self else { return }
            self.categories.value = results
            self.tagCollectionView.reloadData()
            self.tagCollectionView.selectItem(at: IndexPath(item: self.subIndex, section: 0), animated: false, scrollPosition: .left)
            ///태그 갯수에 따라 컨테이너 뷰 높이 동적으로 변경하기
            self.tagDynamicHeight = self.tagCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.heightConstraint.constant = self.tagDynamicHeight
            self.containerViewHeight = self.tagDynamicHeight + 20
            ///폴더 셀이 태그따라서 안올라가도록 수정
            self.folderCollectionView.contentInset.top = self.containerViewHeight + 15
            self.folderCollectionView.verticalScrollIndicatorInsets.top = self.containerViewHeight
            self.view.layoutIfNeeded()
        }
        
        viewModel.outputs.categoryDetailFolders.bind { [weak self] results in
            guard let self = self else { return }
            self.view.hideToastActivity()
            if let last = results.last?.index {
                self.lastFolderIndex = last
            }
            self.categoryDetailFolders.value.append(contentsOf: results)
            self.folderCollectionView.reloadData()
            
            if results.count < Constant.pageLimit {
                self.fetchMore = false
            } else {
                self.fetchMore = true
            }
        }
    }
    
    private func fetchData() {
        view.makeToastActivity(ToastPosition.center)
        fetchMore = false
        print("lastFolderIndex", lastFolderIndex)
        viewModel.inputs.fetchCategoryDetailFolder(mainIndex: mainIndex+1, subIndex: subIndex, lastFolder: lastFolderIndex, completion: nil)
        
    }
    

    private func updateUI() {
        titleLabel.text = "\(categoryMain[mainIndex]) 카테고리"
        textView.layer.zPosition = 1
        containerView.layer.zPosition = -1
        folderCollectionView.layer.zPosition = -2
    }
    
    @objc private func pullToRefresh() {
        prepareFetchData()
        fetchMore = false
        viewModel.inputs.fetchCategoryDetailFolder(mainIndex: mainIndex+1, subIndex: subIndex, lastFolder: lastFolderIndex) {  [weak self] in
            guard let self = self else { return }
            
            print("refresh")
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func searchButtonTapped() {
        guard let searchLinkVC = SearchInFolderViewController.storyboardInstance() else { return }
        
        searchLinkVC.modalTransitionStyle = .crossDissolve
        searchLinkVC.modalPresentationStyle = .overCurrentContext
        
        homeNavigationController?.present(searchLinkVC, animated: true, completion: nil)
    }
    
    private func prepareFolderCollectionView() {
        folderCollectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        folderCollectionView.register(UINib(nibName: FolderCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        folderCollectionView.register(UINib(nibName: FolderHeaderView.reuseableViewIndetifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FolderHeaderView.reuseableViewIndetifier)
        
        folderCollectionView.dataSource = self
        folderCollectionView.delegate = self
    }
    
    private func prepareTagCollectionView() {
        let nib: UINib = UINib(nibName: SurfingCategoryTagCell.cellIdentifier, bundle: nil)
        tagCollectionView.register(nib, forCellWithReuseIdentifier: SurfingCategoryTagCell.cellIdentifier)
        
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        tagCollectionView.collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
    }
    
    private func prepareRefreshControler() {
        folderCollectionView.refreshControl = refreshControl
        refreshControl.bounds.origin.x = 15
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
    
    private func prepareFetchData() {
        lastFolderIndex = 0
        fetchMore = true
        categoryDetailFolders.value = []
    }
}


extension CategoryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return categories.value.count
        case 1:
            return categoryDetailFolders.value.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            guard let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: SurfingCategoryTagCell.cellIdentifier, for: indexPath) as? SurfingCategoryTagCell else { fatalError() }
            tagCell.update(by: categories.value[indexPath.item])
            
            return tagCell
        case 1:
            guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }
            if categoryDetailFolders.value.count > 0 {
                folderCell.update(by: categoryDetailFolders.value[indexPath.item])
            }
            return folderCell
        default:
            return UICollectionViewCell()
        }
    }
  
    //MARK:- scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentYoffset = folderCollectionView.contentOffset.y
        let contentHeight = folderCollectionView.contentSize.height
        let scrollViewHeight = folderCollectionView.frame.size.height
        let delta = contentYoffset - lastContentOffset
        
        if delta < 0 {
            //스크롤 내릴 때
            if scrollViewHeight + contentYoffset <= contentHeight + 15, contentHeight + 30 > scrollViewHeight {
                tagTopConstraint.constant = min(tagTopConstraint.constant - delta, 0)
            }
        } else {
            //스크롤 올릴 때
            if contentYoffset + containerViewHeight + 15 >= 0, contentHeight + 30 > scrollViewHeight  {
                tagTopConstraint.constant = max(-containerViewHeight, tagTopConstraint.constant - delta)
            }
        }
        
        lastContentOffset = contentYoffset
        
        if contentYoffset > contentHeight - scrollViewHeight {
            if fetchMore {
                fetchData()
                DEBUG_LOG(lastFolderIndex)
            }
        }
    }
}

extension CategoryDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 0:
            folderCollectionView.setContentOffset(.init(x: -15, y: -containerViewHeight - 15), animated: false)
            subIndex = categories.value[indexPath.row].detailIndex
            
            prepareFetchData()
            fetchData()

//            folderCollectionView.reloadData()
            
        case 1:
            guard let folderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
            folderDetailVC.homeNavigationController = homeNavigationController
            folderDetailVC.folderIndex = categoryDetailFolders.value[indexPath.item].index
            
            homeNavigationController?.pushViewController(folderDetailVC, animated: true)
        default:
            return
        }

    }
}

extension CategoryDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 0:
            let itemSize = categories.value[indexPath.item].detailName.size(withAttributes: [ NSAttributedString.Key.font : UIFont(name: "NotoSansKR-Medium", size: 14)!]).width
            let width: CGFloat = itemSize + 40
            let height: CGFloat = 34
            
            return CGSize(width: width, height: height)
        case 1:
            let width: CGFloat = (view.frame.width - 47) / 2
            let height: CGFloat = 214
            
            return CGSize(width: width, height: height)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    
}
