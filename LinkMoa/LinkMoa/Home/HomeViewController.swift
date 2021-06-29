//
//  HomeViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/01/31.
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet private weak var topMenuCollectionView: UICollectionView!
    @IBOutlet private weak var containerView: UIView!
    
    private let topMenuSectionNames: [String] = ["나의 링크달", "서핑하기"]
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private var pages: [UIViewController] = []
    private var selectedTopMenuView: UIView = UIView()
    private var isTopMenuSelected: Bool = false
    private var searchTarget: SearchTarget = .my

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let jwtToken = TokenManager().jwtToken else { fatalError() }
        print("❤️JWT", jwtToken)
        
        preparePageViewController()
        prepareTopMenuCollectionView()
        prepareSelectedTopMenuView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func preparePageViewController() {
        guard let homeFolderVC = FolderViewController.storyboardInstance() else { fatalError() }
        
        guard let surfingVC = SurfingViewController.storyboardInstance() else { fatalError() }
        
        homeFolderVC.homeNavigationController = navigationController as? HomeNavigationController
        surfingVC.homeNavigationController = navigationController as? HomeNavigationController
        
        pages = [homeFolderVC, surfingVC]
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([surfingVC], direction: .forward, animated: true, completion: nil)
        pageViewController.setViewControllers([homeFolderVC], direction: .forward, animated: true, completion: nil)
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        containerView.addSubview(pageViewController.view)
        constaintPageViewControllerView()
    }
    
    private func prepareTopMenuCollectionView() {
        topMenuCollectionView.dataSource = self
        topMenuCollectionView.delegate = self
        topMenuCollectionView.register(UINib(nibName: TopMenuCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: TopMenuCell.cellIdentifier)
    }
    
    private func prepareSelectedTopMenuView() {
        // MARK: - 97.6??
        selectedTopMenuView.frame = CGRect(x: 18, y: 47, width: 97.6, height: 3)
        selectedTopMenuView.backgroundColor = .linkMoaBlackColor
        topMenuCollectionView.addSubview(selectedTopMenuView)
    }
    
    private func scrollSelectedTabView(scrollToIndexPath indexPath: IndexPath) {
        let homeNC = navigationController as? HomeNavigationController
        homeNC?.addButtonView.isHidden = (indexPath.item == 0) ? false : true
        
        let prevIndexPath = IndexPath(item: indexPath.item == 0 ? 1 : 0, section: 0)
        
        UIView.animate(withDuration: 0.15) {
            if let destinationCell = self.topMenuCollectionView.cellForItem(at: indexPath) as? TopMenuCell {
                self.selectedTopMenuView.frame.size.width = destinationCell.frame.width
                self.selectedTopMenuView.frame.origin.x = destinationCell.frame.origin.x
                
                destinationCell.titleLabel.layer.opacity = 1
                destinationCell.titleLabel.textColor = .linkMoaBlackColor
            }
            
            if let startCell = self.topMenuCollectionView.cellForItem(at: prevIndexPath) as? TopMenuCell {
                startCell.titleLabel.layer.opacity = 0.3
                startCell.titleLabel.textColor = .linkMoaGrayColor
            }
        }
    }
    
    private func setPageController(setToIndexPath indexPath: IndexPath) {
        let direction: UIPageViewController.NavigationDirection = indexPath.item == 0 ? .reverse : .forward
        
        pageViewController.setViewControllers([pages[indexPath.item]], direction: direction, animated: true, completion: nil)
        
        if indexPath.item == 0 {
            searchTarget = .my
        } else {
            searchTarget = .surf
        }
        
    }
    
    private func constaintPageViewControllerView() {
        let pageContentView: UIView = pageViewController.view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        pageContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageContentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageContentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageContentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageContentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @IBAction private func searchButtonTapped() {
        guard let searchFolderNC = SearchMainNavigationController.storyboardInstance() else { return }
        
        searchFolderNC.modalTransitionStyle = .crossDissolve
        searchFolderNC.modalPresentationStyle = .fullScreen
        searchFolderNC.searchTarget = searchTarget
        present(searchFolderNC, animated: true, completion: nil)
    }
    
    @IBAction func myPageButtonTapped(_ sender: Any) {
        guard let myPageVC = UIStoryboard(name: "MyPage", bundle: nil).instantiateInitialViewController() as? MyPageNavigationController else { return }
//        guard let myPageVC = MyPageViewController.storyboardInstance() else { return }
        
        myPageVC.modalTransitionStyle = .crossDissolve
        myPageVC.modalPresentationStyle = .fullScreen
        present(myPageVC, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topMenuSectionNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let titleCell = collectionView.dequeueReusableCell(withReuseIdentifier: TopMenuCell.cellIdentifier, for: indexPath) as? TopMenuCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0, !isTopMenuSelected { // first cell init
            titleCell.titleLabel.layer.opacity = 1
            titleCell.titleLabel.textColor = UIColor(rgb: 0x303335)
            isTopMenuSelected.toggle()
        }
        
        titleCell.titleLabel.text = topMenuSectionNames[indexPath.item]
        return titleCell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollSelectedTabView(scrollToIndexPath: indexPath)
        setPageController(setToIndexPath: indexPath)
    }
}

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == 1 {
            let prevIndex = index - 1
            let nc = navigationController as? HomeNavigationController
            nc?.addButtonView.isHidden = true
            
            return pages[prevIndex]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == 0 {
            let nextIndex = index + 1
            let nc = navigationController as? HomeNavigationController
            nc?.addButtonView.isHidden = false
            
            return pages[nextIndex]
        }
        
        return nil
    }
}

extension HomeViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        guard let index = pages.lastIndex(of: currentVC) else { return }
        
        scrollSelectedTabView(scrollToIndexPath: IndexPath(item: index, section: 0))
        setPageController(setToIndexPath: IndexPath(item: index, section: 0))
    }
}
