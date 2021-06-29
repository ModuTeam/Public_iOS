//
//  CategoryDetailViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

class CategoryDetailViewController: UIViewController {
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tagCollectionView: UICollectionView!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var tagTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var blueViewHeightConstraint: NSLayoutConstraint!
    
    weak var homeNavigationController: HomeNavigationController?
    private let refreshControl = UIRefreshControl()
    private let categoryMain: [String] = ["개발", "디자인", "마케팅/광고", "기획", "기타"]
    private var fetchMore: Bool = false
    private var lastContentOffset: CGFloat = 0
    private var tagDynamicHeight: CGFloat = 0
    private var containerViewHeight: CGFloat = 0
    private var tagLength: [CGFloat] = []
    private var fetchCounter: Int = 0
    var mainIndex: Int = 0
    var subIndex: Int = 0
    var lastFolderIndex: Int = 0
   
    private let viewModel: CategoryFolderViewModel = CategoryFolderViewModel()
    private lazy var inputs: CategoryFolderViewModel.Input = .init(
        fetchFolder: folderTrigger.asSignal(),
        resetFolder: resetTrigger.asSignal(),
        fetchCategory: tagTrigger.asSignal()
    )
    private lazy var outputs: CategoryFolderViewModel.Output = viewModel.transform(input: inputs)
    
    private let folderTrigger = PublishRelay<(main: Int, sub: Int, last: Int)>()
    private let resetTrigger = PublishRelay<Void>()
    private let tagTrigger = PublishRelay<Int>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        DEBUG_LOG("")
        bind()
        prepareNavigationBar()
        prepareRefreshControler()
        prepareTagCollectionView()
        prepareFolderCollectionView()
        updateUI()
        
        tagTrigger.accept(mainIndex)
        resetFolderData()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 처음에 스크롤되는 문제 해결이 안돼서 임시로 빼놓음
        scrollBind()
    }
    
    private func bind() {
        outputs.categories
            .drive(tagCollectionView.rx.items(cellIdentifier: SurfingCategoryTagCell.cellIdentifier, cellType: SurfingCategoryTagCell.self)) {_, result, cell in
                cell.update(by: result)
            }.disposed(by: disposeBag)

        outputs.categories
            .drive { [weak self] result in
                guard let self = self else { return }
                DEBUG_LOG("")
                self.tagLength = result.map { $0.detailName.size(withAttributes: [ NSAttributedString.Key.font: UIFont(name: "NotoSansKR-Medium", size: 14)!]).width + 40}
                
                self.tagCollectionView.selectItem(at: IndexPath(item: self.subIndex, section: 0), animated: false, scrollPosition: .left)

                // 태그 갯수에 따라 컨테이너 뷰 높이 동적으로 변경하기
                self.tagDynamicHeight = self.tagCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.heightConstraint.constant = self.tagDynamicHeight
                self.containerViewHeight = self.tagDynamicHeight + 20
                // 폴더 셀이 태그따라서 안올라가도록 수정
                self.folderCollectionView.contentInset.top = self.containerViewHeight + 15
                self.folderCollectionView.verticalScrollIndicatorInsets.top = self.containerViewHeight
                self.view.layoutIfNeeded()
            }
            .disposed(by: disposeBag)

        tagCollectionView.rx.modelSelected(CategoryInfo.DetailCategoryList.self)
            .bind { [weak self] result in
                guard let self = self else { return }
                self.folderCollectionView.setContentOffset(.init(x: -15, y: -self.containerViewHeight - 15), animated: false)
                self.subIndex = result.detailIndex
                self.resetFolderData()
                self.fetchData()
                DEBUG_LOG("")
            }.disposed(by: disposeBag)
        
        outputs.categoryDetailFolders
            .drive(folderCollectionView.rx.items(cellIdentifier: FolderCell.cellIdentifier, cellType: FolderCell.self)) { _, result, cell in
                cell.update(by: result)
            }.disposed(by: disposeBag)

        outputs.categoryDetailFolders
            .drive { [weak self] result in
                guard let self = self else { return }
                
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                
                if let last = result.last?.folderIndex {
                    self.lastFolderIndex = last
                    self.fetchCounter += 1
                }
                
                self.fetchMore = result.count < Constant.pageLimit * self.fetchCounter ? false : true
                DEBUG_LOG("\(self.lastFolderIndex), \(result.count), \(Constant.pageLimit * self.fetchCounter), \(self.fetchMore)")
            }
            .disposed(by: disposeBag)
        
        folderCollectionView.rx.modelSelected(IntegratedFolder.self)
            .bind { [weak self] result in
                guard let self = self else { return }
                guard let vc = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
                vc.homeNavigationController = self.homeNavigationController
                vc.folderIndex = result.folderIndex
                self.homeNavigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
                
        outputs.errorMessage
            .emit { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
    private func scrollBind() {
        folderCollectionView.rx.contentOffset
            .map { $0.y }
            .bind { [weak self] contentYoffset in
                guard let self = self else { return }
                let contentHeight = self.folderCollectionView.contentSize.height
                let scrollViewHeight = self.folderCollectionView.frame.size.height
                let delta = contentYoffset - self.lastContentOffset
             
                if delta < 0 {
                    // 스크롤 내릴 때
                    if scrollViewHeight + contentYoffset <= contentHeight + 15, contentHeight + 30 > scrollViewHeight {
                        self.tagTopConstraint.constant = min(self.tagTopConstraint.constant - delta, 0)
                    }
                } else {
                    // 스크롤 올릴 때
                    if contentYoffset + self.containerViewHeight + 15 >= 0, contentHeight + 30 > scrollViewHeight {
                        self.tagTopConstraint.constant = max(-self.containerViewHeight, self.tagTopConstraint.constant - delta)
                    }
                }
                
                self.lastContentOffset = contentYoffset
                
                if contentYoffset > contentHeight - scrollViewHeight {
                    if self.fetchMore {
                        self.fetchData()
                        DEBUG_LOG("fetchMore, \(self.lastFolderIndex)")
                    }
                }
            }.disposed(by: disposeBag)
    }
    
    private func fetchData() {
        fetchMore = false
        folderTrigger.accept((main: mainIndex, sub: subIndex, last: lastFolderIndex))
    }
    
    private func updateUI() {
        titleLabel.text = "\(categoryMain[mainIndex]) 카테고리"
        textView.layer.zPosition = 1
        containerView.layer.zPosition = -1
        folderCollectionView.layer.zPosition = -2
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        blueViewHeightConstraint.constant = Device.statusBarHeight + Device.navigationBarHeight + 44
    }
    
    @objc private func pullToRefresh() {
        resetFolderData()
        fetchData()
    }

    private func resetFolderData() {
        lastFolderIndex = 0
        fetchCounter = 0
        resetTrigger.accept(())
    }
    
    private func prepareFolderCollectionView() {
        let nib1 = UINib(nibName: FolderCell.cellIdentifier, bundle: nil)
        let nib2 = UINib(nibName: FolderHeaderView.reuseableViewIndetifier, bundle: nil)
        folderCollectionView.register(nib1, forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        folderCollectionView.register(nib2, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FolderHeaderView.reuseableViewIndetifier)
        
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = (folderCollectionView.frame.width - 47) / 2
        let height: CGFloat = 214
        layout.itemSize = CGSize(width: width, height: height)
        
        folderCollectionView.collectionViewLayout = layout
        folderCollectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private func prepareTagCollectionView() {
        let nib: UINib = UINib(nibName: SurfingCategoryTagCell.cellIdentifier, bundle: nil)
        tagCollectionView.register(nib, forCellWithReuseIdentifier: SurfingCategoryTagCell.cellIdentifier)
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.delegate = self
        tagCollectionView.collectionViewLayout = layout
    }
    
    private func prepareRefreshControler() {
        folderCollectionView.refreshControl = refreshControl
        refreshControl.bounds.origin.x = 15
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
}

extension CategoryDetailViewController: TagLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, widthForTagAtIndexPath indexPath: IndexPath) -> CGFloat {
        return tagLength[indexPath.item]
    }
}
