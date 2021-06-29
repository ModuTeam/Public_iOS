//
//  SearchMainViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/10.
//

import UIKit
import RxSwift
import RxCocoa

enum SearchTarget: Int {
    case surf = 0
    case my = 1
}

final class SearchMainViewController: UIViewController {
    
    @IBOutlet private weak var topMenuCollectionView: CustomCollectionView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private var resultCountStrings: BehaviorRelay<[String]> = BehaviorRelay(value: ["폴더(0)개", "링크(0)개"])
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private var pages: [UIViewController] = []
    private var searchFolderResultVC: SearchFolderResultViewController?
    private var searchLinkResultVC: SearchLinkResultViewController?
    
    private var selectedTopMenuView: UIView = UIView()
    private var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    private var isTopMenuSelected: Bool = false
    private var isTopMenuViewPresented: Bool = false
    
    var searchTarget: SearchTarget = .my

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchTarget()
        prepareTopMenuCollectionView()
        preparePageViewController()
        prepareSearchTextField()
        prepareSelectedTopMenuView()
        bind()
    }

    private func bind() {
        guard let folderVC = self.searchFolderResultVC, let linkVC = self.searchLinkResultVC else { return }

        let folder = folderVC.outputs.count
        let link = linkVC.outputs.count

        Driver.zip(folder, link) { ($0, $1) }
            .drive { count in
                let folder = "폴더(\(count.0.toAbbreviationString))개"
                let link = "링크(\(count.1.toAbbreviationString))개"
                self.resultCountStrings.accept([folder, link])
                self.topMenuCollectionView.reloadDataWithCompletion { [weak self] in
                    guard let self = self else { return }
                    DEBUG_LOG("두번 호출 되는 이유가 뭘까?")
                    self.topMenuCollectionView.selectItem(at: self.selectedIndexPath, animated: false, scrollPosition: .bottom)
                    self.scrollSelectedTopMenuView(scrollTo: self.selectedIndexPath)
                }
            }
            .disposed(by: self.disposeBag)
        
        searchTextField.rx.text
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .debounce(.milliseconds(500))
            .drive { [weak self] text in
                guard let self = self, let folderVC = self.searchFolderResultVC, let linkVC = self.searchLinkResultVC else { return }
                folderVC.targetString.accept(text ?? "")
                linkVC.targetString.accept(text ?? "")
            }
            .disposed(by: disposeBag)

        clearButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.searchTextField.text = ""
                self.searchTextField.sendActions(for: .valueChanged)
            }
            .disposed(by: disposeBag)
   
        backButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        topMenuCollectionView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                self.selectedIndexPath = indexPath
                self.scrollSelectedTopMenuView(scrollTo: indexPath)
                self.setPageController(setToIndexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
        resultCountStrings
            .asDriver()
            .drive(topMenuCollectionView.rx.items(cellIdentifier: TopMenuCell.cellIdentifier, cellType: TopMenuCell.self)) { _, result, cell in
                cell.titleLabel.text = result
            }
            .disposed(by: disposeBag)
        
        searchLinkResultVC?.scrollTrigger
            .bind { [weak self] bool in
                guard let self = self else { return }
                self.view.endEditing(bool)
            }
            .disposed(by: disposeBag)
        
        searchFolderResultVC?.scrollTrigger
            .bind { [weak self] bool in
                guard let self = self else { return }
                self.view.endEditing(bool)
            }
            .disposed(by: disposeBag)
    }
    
    private func prepareSearchTarget() {
        guard let nav = navigationController as? SearchMainNavigationController else { fatalError() }
        searchTarget = nav.searchTarget
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setPageController(setToIndexPath indexPath: IndexPath) {
        let direction: UIPageViewController.NavigationDirection = indexPath.item == 0 ? .reverse : .forward
        pageViewController.setViewControllers([pages[indexPath.item]], direction: direction, animated: true, completion: nil)
    }
    
    private func preparePageViewController() {
        guard let folderListVC = SearchFolderResultViewController.storyboardInstance() else { fatalError() }
        guard let linkListVC = SearchLinkResultViewController.storyboardInstance() else { fatalError() }
        
        folderListVC.searchTarget = searchTarget
        linkListVC.searchTarget = searchTarget
 
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
        constraintPageViewControllerView()
    }
    
    private func constraintPageViewControllerView() {
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
        label.text = resultCountStrings.value[0]
        label.font = UIFont(name: "NotoSansKR-Medium", size: 19)
        let width = label.intrinsicContentSize.width

        selectedTopMenuView.frame = CGRect(x: 0, y: 46, width: width, height: 3)
        selectedTopMenuView.backgroundColor = UIColor.linkMoaGrayColor
        topMenuCollectionView.addSubview(selectedTopMenuView)
        self.topMenuCollectionView.selectItem(at: self.selectedIndexPath, animated: false, scrollPosition: .bottom)
    }
    
    private func prepareTopMenuCollectionView() {
        let nib = UINib(nibName: TopMenuCell.cellIdentifier, bundle: nil)
        topMenuCollectionView.register(nib, forCellWithReuseIdentifier: TopMenuCell.cellIdentifier)
    }
    
    private func scrollSelectedTopMenuView(scrollTo indexPath: IndexPath) {
        UIView.animate(withDuration: 0.15) {
            if let cell = self.topMenuCollectionView.cellForItem(at: indexPath) as? TopMenuCell {
                self.selectedTopMenuView.frame.size.width = cell.frame.width
                self.selectedTopMenuView.frame.origin.x = cell.frame.origin.x
            }
        }
    }
        
    private func prepareSearchTextField() {
        searchTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
 
    @objc private func adjustInputView(noti: Notification) {
            guard let userInfo = noti.userInfo else { return }
            guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let height = keyboardFrame.height
        bottomConstraint.constant = noti.name == UIResponder.keyboardWillShowNotification ? height : 0
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
        
        scrollSelectedTopMenuView(scrollTo: IndexPath(item: index, section: 0))
    }
}
