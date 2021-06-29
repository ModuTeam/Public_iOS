//
//  LinkListViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/10.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

final class SearchLinkResultViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet private weak var linkCollectionView: UICollectionView!
    private var pageIndex: Int = 0
    private var fetchMore: Bool = true
    private var fetchCounter: Int = 0
    private let viewModel: SearchLinkViewModel = SearchLinkViewModel()
    private let disposeBag = DisposeBag()
    private lazy var inputs: SearchLinkViewModel.Input = .init(
        searchInput: inputTrigger.asSignal(),
        resetInput: resetTrigger.asSignal()
    )
    lazy var outputs: SearchLinkViewModel.Output = viewModel.transform(input: inputs)
    private let inputTrigger = PublishRelay<(word: String, page: Int, isMine: Int)>()
    private let resetTrigger = PublishRelay<Void>()
    private var tempString = ""
    var searchTarget: SearchTarget = .my
    var targetString = PublishRelay<String>()
    let scrollTrigger = PublishRelay<Bool>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLinkCollectionView()
        bind()
    }
    
    private func bind() {
        targetString
            .subscribe(onNext: { [weak self] str in
                guard let self = self else { return }
                self.fetchMore = false
                self.fetchCounter = 0
                self.pageIndex = 0
                self.resetTrigger.accept(())
                self.inputTrigger.accept((word: str, page: self.pageIndex, isMine: self.searchTarget.rawValue))
                self.tempString = str
                self.pageIndex = 1
            })
            .disposed(by: disposeBag)
        
        outputs.result
            .drive(linkCollectionView.rx.items(cellIdentifier: LinkCell.cellIdentifier, cellType: LinkCell.self)) {_, result, cell in
                cell.update(by: result)
            }
            .disposed(by: disposeBag)
        
        outputs.result
            .drive { [weak self] result in
                guard let self = self else { return }
                if result.last != nil {
                    self.fetchCounter += 1
                }
                self.fetchMore = result.count < Constant.pageLimit * self.fetchCounter ? false : true
            }
            .disposed(by: disposeBag)
        
        linkCollectionView.rx.modelSelected(SearchLink.Result.self)
            .bind { [weak self] result in
                guard let self = self else { return }
                guard let webVC = WebViewController.storyboardInstance() else { return }

                if let url = URL(string: result.url) {
                    webVC.url = url
                    webVC.modalPresentationStyle = .fullScreen
                    self.present(webVC, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        linkCollectionView.rx.contentOffset
            .map { $0.y }
            .bind { [weak self] contentYoffset in
                guard let self = self else { return }
                self.scrollTrigger.accept(true)
                let contentYoffset = self.linkCollectionView.contentOffset.y
                let contentHeight = self.linkCollectionView.contentSize.height
                let scrollViewHeight = self.linkCollectionView.frame.size.height
                
                if contentYoffset > contentHeight - scrollViewHeight {
                    if self.fetchMore {
                        self.fetchNextData()
//                        DEBUG_LOG(self.pageIndex)
                    }
                }
            }
            .disposed(by: disposeBag)

    }
    
    private func fetchNextData() {
        fetchMore = false
        inputTrigger.accept((word: tempString, page: pageIndex, isMine: searchTarget.rawValue))
        pageIndex += 1
    }

    private func prepareLinkCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = linkCollectionView.frame.width - (18 * 2)
        let height: CGFloat = 83
        layout.itemSize = CGSize(width: width, height: height)
        linkCollectionView.collectionViewLayout = layout
        linkCollectionView.contentInset.top = 15
        linkCollectionView.contentInset.bottom = 50
        linkCollectionView.register(UINib(nibName: LinkCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: LinkCell.cellIdentifier)
    }
}
