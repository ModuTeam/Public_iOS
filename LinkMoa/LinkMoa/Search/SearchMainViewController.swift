//
//  SearchMainViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/25.
//

import UIKit

enum SearchTarget: Int {
    case surf = 0
    case my = 1
}

final class SearchMainViewController: UIViewController {
    
    @IBOutlet private weak var topMenuCollectionView: CustomCollectionView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var searchWord: String = ""
    private lazy var topMenuSectionNames: [String] = ["폴더(0개)", "링크(0개)"]
  
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private var pages: [UIViewController] = []
    private var searchFolderResultVC: SearchFolderResultViewController?
    private var searchLinkResultVC: SearchLinkResultViewController?
    
    private var selectedTopMenuView: UIView = UIView()
    private var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var isTopMenuSelected: Bool = false
    private var isTopMenuViewPresented: Bool = false
    
    var searchTarget: SearchTarget = .my

    private var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchTarget()
        prepareTopMenuCollectionView()
        preparePageViewController()
        prepareSearchTextField()
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
    
    @IBAction func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        searchTextField.text = ""
        searchWord = ""
    }
    
    static func storyboardInstance() -> SearchMainViewController? {
        let storyboard = UIStoryboard(name: SearchMainViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }

    private func prepareSearchTarget() {
        guard let nav = navigationController as? SearchMainNavigationController else { fatalError() }
        searchTarget = nav.searchTarget
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func preparePageViewController() {
        guard let folderListVC = SearchFolderResultViewController.storyboardInstance() else { fatalError() }
        guard let linkListVC = SearchLinkResultViewController.storyboardInstance() else { fatalError() }
        
        folderListVC.searchTarget = searchTarget
        linkListVC.searchTarget = searchTarget
        folderListVC.reloadDelegate = self
        linkListVC.reloadDelegate = self
        searchFolderResultVC = folderListVC
        searchLinkResultVC = linkListVC
        
        pages = [folderListVC, linkListVC]
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([linkListVC], direction: .forward, animated: true, completion: nil)
        pageViewController.setViewControllers([folderListVC], direction: .forward, animated: true, completion: nil)
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        containerView.addSubview(pageViewController.view)
        constaintPageViewControllerView()
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
    
    private func prepareSelectedTopMenuView() {
        let label = UILabel()
        label.text = topMenuSectionNames[0]
        label.font = UIFont(name: "NotoSansKR-Medium", size: 19)
        let size = label.intrinsicContentSize.width
        
        selectedTopMenuView.frame = CGRect(x: 0, y: 46, width: size, height: 3)
        selectedTopMenuView.backgroundColor = UIColor.linkMoaGrayColor
        topMenuCollectionView.addSubview(selectedTopMenuView)
    }
    
    private func prepareTopMenuCollectionView() {
        topMenuCollectionView.dataSource = self
        topMenuCollectionView.delegate = self
        topMenuCollectionView.register(UINib(nibName: TopMenuCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: TopMenuCell.cellIdentifier)
    }
    
    private func scrollSelectedTopMenuView(scrollToIndexPath indexPath: IndexPath) {
        let homeNC = navigationController as? HomeNavigationController
        homeNC?.addButtonView.isHidden = (indexPath.item == 0) ? false : true
    
        let prevIndexPath = IndexPath(item: indexPath.item == 0 ? 1 : 0, section: 0)
        selectedIndexPath = indexPath
        
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
    }
    
    private func prepareSearchTextField() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
    }
    
    @objc func timerFunc() {
        guard let word = searchTextField.text else { return }
        searchWord = word
        if searchWord == searchTextField.text {
            timer.invalidate()
        }
        
        searchFolderResultVC?.searchWord = word
        searchLinkResultVC?.searchWord = word
    }
    
    @objc private func adjustInputView(noti: Notification) {
            guard let userInfo = noti.userInfo else { return }
            // TODO: 키보드 높이에 따른 인풋뷰 위치 변경
            guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            
            if noti.name == UIResponder.keyboardWillShowNotification{
                let height = keyboardFrame.height
                bottomConstraint.constant = height
            } else {
                bottomConstraint.constant = 0
            }
        }
}

extension SearchMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topMenuSectionNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let titleCell = collectionView.dequeueReusableCell(withReuseIdentifier: TopMenuCell.cellIdentifier, for: indexPath) as? TopMenuCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0, !isTopMenuSelected { // first cell init
            titleCell.titleLabel.layer.opacity = 1
            titleCell.titleLabel.textColor = .linkMoaBlackColor
            isTopMenuSelected.toggle()
        }

        titleCell.titleLabel.text = topMenuSectionNames[indexPath.item]
        return titleCell
    }
}

extension SearchMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollSelectedTopMenuView(scrollToIndexPath: indexPath)
        setPageController(setToIndexPath: indexPath)
    }
}

extension SearchMainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == 1 {
            let prevIndex = index - 1
            return pages[prevIndex]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        if index == 0 {
            let nextIndex = index + 1
            return pages[nextIndex]
        }
        
        return nil
    }
}

extension SearchMainViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        guard let index = pages.lastIndex(of: currentVC) else { return }
        
        scrollSelectedTopMenuView(scrollToIndexPath: IndexPath(item: index, section: 0))
    }
}


extension SearchMainViewController: ReloadDelegate {
    func reloadFolderCount(count: String) {
        topMenuSectionNames[0] = count
        
        topMenuCollectionView.reloadDataWithCompletion { [weak self] in
            guard let self = self else { return }
            self.scrollSelectedTopMenuView(scrollToIndexPath: self.selectedIndexPath)
        }
    }
    
    func reloadLinkCount(count: String) {
        topMenuSectionNames[1] = count
        
        topMenuCollectionView.reloadDataWithCompletion { [weak self] in
            guard let self = self else { return }
            self.scrollSelectedTopMenuView(scrollToIndexPath: self.selectedIndexPath)
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

protocol ReloadDelegate {
    func reloadFolderCount(count: String)
    func reloadLinkCount(count: String)
    func hideKeyboard()
}
