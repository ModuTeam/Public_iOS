//
//  SurfingViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SurfingViewController: UIViewController {
    
    @IBOutlet weak var surfingCollectionView: UICollectionView!
    
    weak var homeNavigationController: HomeNavigationController?
    
    private let viewModel: SurfingViewModel = SurfingViewModel()
    private lazy var inputs: SurfingViewModel.Input = .init(
        fetchTopTenFolders: topTenTrigger.asSignal(),
        fetchLikedFolders: likedTrigger.asSignal()
    )
    private lazy var outputs: SurfingViewModel.Output = viewModel.transform(input: inputs)
    
    private let topTenTrigger = PublishRelay<Void>()
    private let likedTrigger = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topTenTrigger.accept(())
        likedTrigger.accept(())
    }
    
    private func bind() {
        let dataSource = dataSource()
        
        outputs.sections
            .drive(surfingCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        outputs.sections
            .drive { [weak self] items in
                guard let self = self else { return }
                let isHidden = !items[2].items.isEmpty
                self.surfingCollectionView.collectionViewLayout = self.createSectionLayout(isFooterHidden: isHidden)
            }
            .disposed(by: disposeBag)
        
        surfingCollectionView.rx.modelSelected(SurfingSectionItem.self)
            .bind { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .topTenItem(folder: let folder):
                    guard let surfingFolderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
                    surfingFolderDetailVC.homeNavigationController = self.homeNavigationController
                    surfingFolderDetailVC.folderIndex =
                        folder.folderIndex
                    self.homeNavigationController?.pushViewController(surfingFolderDetailVC, animated: true)
                case .categoryItem(index: let index):
                    guard let categoryDetailVC = CategoryDetailViewController.storyboardInstance() else { fatalError() }
                    categoryDetailVC.homeNavigationController = self.homeNavigationController
                    categoryDetailVC.mainIndex = index
                    self.homeNavigationController?.pushViewController(categoryDetailVC, animated: true)
                case .likedItem(folder: let folder):
                    guard let surfingFolderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
                    surfingFolderDetailVC.homeNavigationController = self.homeNavigationController
                    surfingFolderDetailVC.folderIndex = folder.folderIndex
                    self.homeNavigationController?.pushViewController(surfingFolderDetailVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        outputs.errorMessage
            .emit { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<SurfingSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<SurfingSectionModel>(configureCell: { dataSource, collectionView, indexPath, _ in
            switch dataSource[indexPath] {
            case .topTenItem(folder: let folder):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { return UICollectionViewCell() }
                cell.update(by: folder)
                return cell
            case .categoryItem:
                guard let cell: SurfingCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: SurfingCategoryCell.cellIdentifier, for: indexPath) as? SurfingCategoryCell else { return UICollectionViewCell() }
                cell.index = indexPath.item
                cell.categoryImageView.image = UIImage(named: "category_\(indexPath.item)")
                return cell
            case .likedItem(folder: let folder):
                guard let cell: FolderCell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.cellIdentifier, for: indexPath) as? FolderCell else { return UICollectionViewCell() }
                
                cell.gradientLayer.isHidden = false
                cell.update(by: folder)
                return cell
            }
        }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
            guard let self = self else { fatalError() }
            let headerTitle = ["TOP10 ?????????", "????????????", "?????? ?????????"]
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                if indexPath.section == 0 {
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingSearchHeaderView.reuseableViewIndetifier, for: indexPath) as? SurfingSearchHeaderView else { fatalError() }
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
                    tapGesture.cancelsTouchesInView = false
                    headerView.searchView.addGestureRecognizer(tapGesture)
                    headerView.searchView.isUserInteractionEnabled = true
                    
                    let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.headerViewTapped(_:)))
                    tapGesture2.cancelsTouchesInView = false
                    headerView.titleHeaderView.addGestureRecognizer(tapGesture2)
                    headerView.titleHeaderView.isUserInteractionEnabled = true
                    
                    return headerView
                } else {
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SurfingHeaderView.reuseableViewIndetifier, for: indexPath) as? SurfingHeaderView else { fatalError() }
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.headerViewTapped(_:)))
                    headerView.tag = indexPath.section
                    headerView.gestureRecognizers?.forEach {headerView.removeGestureRecognizer($0)}
                    headerView.addGestureRecognizer(tapGesture)
                    headerView.titleLabel.text = headerTitle[indexPath.section]
                    headerView.moreButton.isHidden = headerView.tag == 1 ? true: false
                    
                    return headerView
                }
                
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SurfingFooterView.reuseableViewIndetifier, for: indexPath) as? SurfingFooterView else { fatalError() }
                return dataSource[2].items.isEmpty ? footerView : UICollectionReusableView()
                
            default:
                fatalError()
            }
        })
        
        outputs.errorMessage
            .emit { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
    private func prepareCollectionView() {
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
    }
    
    func createSectionLayout(isFooterHidden: Bool) -> UICollectionViewCompositionalLayout {
        let compositionalLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, _) -> NSCollectionLayoutSection? in
            // ????????? ??????????????? ???????????? ????????? ?????? ????????? 16??? 1/2?????? ?????????
            let inset: CGFloat = 8
            var itemsPerRow: Int = 2
            // height ??? 214 ??????????????? item inset??? ???????????? ??? ???????????? ???????????? ????????? ????????????
            var height: CGFloat = 214 + inset * 2
            
            // ????????? ????????? ??????????????? ?????? sectionIndex??? ??????
            if sectionIndex == 1 {
                itemsPerRow = 1
                height = 67 + inset * 2
            }
            
            let fraction: CGFloat = 1 / CGFloat(itemsPerRow)
            
            /// item
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
