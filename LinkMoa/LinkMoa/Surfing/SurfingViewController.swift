//
//  SurfingViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/05.
//

import UIKit

final class SurfingViewController: UIViewController {
    
    @IBOutlet weak var surfingCollectionView: UICollectionView!
    
    weak var homeNavigationController: HomeNavigationController?
    
    private let viewModel: SurfingViewModel = SurfingViewModel()
    private let surfingManager =  SurfingManager()
    
    var topTenFolders: Observable<[TopTenFolder.Result]> = Observable([])
    var likedFolders: Observable<[LikedFolder.Result]> = Observable([])
    private var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchTopTenFolder()
        viewModel.inputs.fetchLikedFolders(word: nil, page: 0)
        surfingCollectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        surfingCollectionView.showsVerticalScrollIndicator = true
    }
    
    static func storyboardInstance() -> SurfingViewController? {
        let storyboard = UIStoryboard(name: SurfingViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    private func bind() {
        
        viewModel.outputs.topTenFolders.bind { [weak self] results  in
            guard let self = self else { return }
            self.topTenFolders.value = results
            self.surfingCollectionView.reloadData()
        }
 
        
        viewModel.outputs.likedFolders.bind { [weak self] results  in
            guard let self = self else { return }
            
            self.likedFolders.value = results
            
            //MARK:- 레이아웃 문제 있음
            if self.likedFolders.value.count == 0 {
                self.surfingCollectionView.collectionViewLayout = self.createSectionLayout(isFooterHidden: false)
            } else {
                self.surfingCollectionView.collectionViewLayout = self.createSectionLayout(isFooterHidden: true)
            }
            
            self.surfingCollectionView.reloadData()
//            self.surfingCollectionView.setContentOffset(.zero, animated: false)
            
        }
    }
 
    
    private func prepareCollectionView() {
        surfingCollectionView.collectionViewLayout = createSectionLayout(isFooterHidden: false)
        let nib1 = UINib(nibName: FolderCell.cellIdentifier, bundle: nil)
        let nib2 = UINib(nibName: SurfingCategoryCell.cellIdentifier, bundle: nil)
        let nib3 = UINib(nibName: SurfingHeaderView.reuseableViewIndetifier, bundle: nil)
        let nib4 = UINib(nibName: SurfingFooterView.reuseableViewIndetifier, bundle: nil)
        let nib5 = UINib(nibName: SurfingSearchHeaderView.reuseableViewIndetifier, bundle: nil)
        surfingCollectionView.register(nib1, forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        surfingCollectionView.register(nib2, forCellWithReuseIdentifier: SurfingCategoryCell.cellIdentifier)
        surfingCollectionView.register(nib3, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingHeaderView.reuseableViewIndetifier)
        surfingCollectionView.register(nib4, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SurfingFooterView.reuseableViewIndetifier)
        surfingCollectionView.register(nib5, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingSearchHeaderView.reuseableViewIndetifier)
        surfingCollectionView.dataSource = self
        surfingCollectionView.delegate = self
        
    }
    
    /// Layout
    
    func createSectionLayout(isFooterHidden: Bool) -> UICollectionViewCompositionalLayout {
        let compositionalLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            ///인셋이 좌우상하로 들어가기 때문에 원래 의도한 16의 1/2값을 사용함
            let inset: CGFloat = 8
            //            var rows: Int = 2
            var itemsPerRow: Int = 2
            /// height 는 214 고정값이고 item inset을 적용하면 셀 안쪽으로 작아지기 때문에 인셋추가
            var height: CGFloat = 214 + inset * 2
            
            /// 가운데 섹션만 레이아웃이 달라 sectionIndex로 구분
            if sectionIndex == 1 {
                //                rows = 5
                itemsPerRow = 1
                height = 67 + inset * 2
            }
            
            let fraction: CGFloat = 1 / CGFloat(itemsPerRow)
            
            ///item
            var itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .absolute(height))
            
            if sectionIndex == 1 {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .absolute(height))
            }
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            /// Group
            var groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
            
            if sectionIndex == 1 {
                groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
            }
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            /// Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            /// Supplementary Item
            var headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
            
            if sectionIndex == 0 {
                headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(143))
            }
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            if sectionIndex == 2, isFooterHidden == false {
                let footerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(260))
                let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerItemSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                section.boundarySupplementaryItems = [headerItem, footerItem]
            } else {
                section.boundarySupplementaryItems = [headerItem]
            }
            return section
        })
        
        return compositionalLayout
    }
  
    @objc private func viewTapped() {
        guard let searchFolderNC = SearchMainNavigationController.storyboardInstance() else { return }
        
        searchFolderNC.modalTransitionStyle = .crossDissolve
        searchFolderNC.modalPresentationStyle = .fullScreen
        searchFolderNC.searchTarget = .surf
        present(searchFolderNC, animated: true, completion: nil)
    }
    
    
    @objc private func headerViewTapped(_ sender: UIGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            guard let surfingFolderVC = SurfingFolderViewController.storyboardInstance() else { fatalError() }
            surfingFolderVC.homeNavigationController = homeNavigationController
            surfingFolderVC.surfingFolerType = .topTen
            homeNavigationController?.pushViewController(surfingFolderVC, animated: true)
        case 1:
            print("카테고리는 아무것도 안함")
            
        //            guard let categoryDetailVC = CategoryDetailViewController.storyboardInstance() else { fatalError() }
        //            categoryDetailVC.homeNavigationController = homeNavigationController
        //            homeNavigationController?.pushViewController(categoryDetailVC, animated: true)
        case 2:
            guard let surfingFolderVC = SurfingFolderViewController.storyboardInstance() else { fatalError() }
            surfingFolderVC.homeNavigationController = homeNavigationController
            surfingFolderVC.surfingFolerType = .liked
            homeNavigationController?.pushViewController(surfingFolderVC, animated: true)
        default:
            print(sender.view?.tag ?? "?" )
        }
    }
    
}

extension SurfingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return min(4, topTenFolders.value.count)
        case 1:
            return 5
        case 2:
            return min(4, likedFolders.value.count)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }
            folderCell.update(by: topTenFolders.value[indexPath.row])
            return folderCell
        case 1:
            guard let surfingCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: SurfingCategoryCell.cellIdentifier, for: indexPath) as? SurfingCategoryCell else { fatalError() }
            
            //MARK:- 속도 이슈, 사진크기조절
            surfingCategoryCell.index = indexPath.item
            surfingCategoryCell.categoryImageView.image = UIImage(named: "category_\(indexPath.item)")
            return surfingCategoryCell
        case 2:
            guard let folderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { fatalError() }
            //MARK:- 제약에러있음
            folderCell.gradientLayer.isHidden = false
            folderCell.update(by: likedFolders.value[indexPath.row])
            return folderCell
        default:
            return UICollectionViewCell()
        }
        
    }
}

extension SurfingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let surfingFolderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
            surfingFolderDetailVC.homeNavigationController = homeNavigationController
            surfingFolderDetailVC.folderIndex = topTenFolders.value[indexPath.item].folderIndex
            homeNavigationController?.pushViewController(surfingFolderDetailVC, animated: true)
        case 1:
            guard let categoryDetailVC = CategoryDetailViewController.storyboardInstance() else { fatalError() }
            categoryDetailVC.homeNavigationController = homeNavigationController
            categoryDetailVC.mainIndex = indexPath.item
            homeNavigationController?.pushViewController(categoryDetailVC, animated: true)
        case 2:
            guard let surfingFolderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
            surfingFolderDetailVC.homeNavigationController = homeNavigationController
            surfingFolderDetailVC.folderIndex = likedFolders.value[indexPath.item].folderIndex
            homeNavigationController?.pushViewController(surfingFolderDetailVC, animated: true)
        default:
            print("default")
        }
    }
}

extension SurfingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerTitle = ["TOP10 링크달", "카테고리", "찜한 링크달"]
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 0 {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingSearchHeaderView.reuseableViewIndetifier, for: indexPath) as? SurfingSearchHeaderView else { fatalError() }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
                tapGesture.cancelsTouchesInView = false
                headerView.searchView.addGestureRecognizer(tapGesture)
                headerView.searchView.isUserInteractionEnabled = true
                
                let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:)))
                tapGesture2.cancelsTouchesInView = false
                headerView.titleHeaderView.addGestureRecognizer(tapGesture2)
                headerView.titleHeaderView.isUserInteractionEnabled = true
               
                return headerView
            } else {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingHeaderView.reuseableViewIndetifier, for: indexPath) as? SurfingHeaderView else { fatalError() }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:)))
                tapGesture.delegate = self
                headerView.tag = indexPath.section
                headerView.gestureRecognizers?.forEach {headerView.removeGestureRecognizer($0)}
                headerView.addGestureRecognizer(tapGesture)
                headerView.titleLabel.text = headerTitle[indexPath.section]
                
                if headerView.tag == 1 {
                    headerView.moreButton.isHidden = true
                } else {
                    headerView.moreButton.isHidden = false
                }
                return headerView
            }
        case UICollectionView.elementKindSectionFooter:
            if self.likedFolders.value.count == 0 {
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SurfingFooterView.reuseableViewIndetifier, for: indexPath) as? SurfingFooterView else { fatalError() }
                
                return footerView
            } else {
                return UICollectionReusableView()
            }
        default:
            fatalError()
            break
        }
        
    }
    
}

extension SurfingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
