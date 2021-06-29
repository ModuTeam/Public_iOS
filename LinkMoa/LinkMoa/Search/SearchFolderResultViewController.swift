//
//  SearchFolderResultViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/06/10.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

final class SearchFolderResultViewController: UIViewController {

    @IBOutlet private weak var folderCollectionView: UICollectionView!
    private var pageIndex: Int = 0
    private var fetchMore: Bool = true
    private var fetchCounter: Int = 0
    private let viewModel: SearchFolderViewModel = SearchFolderViewModel()
    private let disposeBag = DisposeBag()
    private lazy var inputs: SearchFolderViewModel.Input = .init(
        searchInput: inputTrigger.asSignal(),
        resetInput: resetTrigger.asSignal()
    )
    lazy var outputs: SearchFolderViewModel.Output = viewModel.transform(input: inputs)
    private let inputTrigger = PublishRelay<(word: String, page: Int, isMine: Int)>()
    private let resetTrigger = PublishRelay<Void>()
    private var tempString = ""
    var searchTarget: SearchTarget = .my
    var targetString = PublishRelay<String>()
    let scrollTrigger = PublishRelay<Bool>()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFolderCollectionView()
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
            })
            .disposed(by: disposeBag)
        
        outputs.result
            .drive(folderCollectionView.rx.items(cellIdentifier: FolderCell.cellIdentifier, cellType: FolderCell.self)) {_, result, cell in
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
                DEBUG_LOG("\(result.count), \(Constant.pageLimit * self.fetchCounter), \(self.fetchMore)")
            }
            .disposed(by: disposeBag)
        
        folderCollectionView.rx.modelSelected(IntegratedFolder.self)
            .bind { [weak self] result in
                guard let self = self else { return }
                switch self.searchTarget {
                case .my:
                    guard let folderDetailVC = FolderDetailViewController.storyboardInstance() else { fatalError() }
                    folderDetailVC.folderIndex = result.folderIndex
                    self.navigationController?.pushViewController(folderDetailVC, animated: true)
                case .surf:
                    guard let folderDetailVC = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
                    folderDetailVC.folderIndex = result.folderIndex
                    self.navigationController?.pushViewController(folderDetailVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        folderCollectionView.rx.contentOffset
            .map { $0.y }
            .bind { [weak self] contentYoffset in
                guard let self = self else { return }
                self.scrollTrigger.accept(true)
                let contentYoffset = self.folderCollectionView.contentOffset.y
                let contentHeight = self.folderCollectionView.contentSize.height
                let scrollViewHeight = self.folderCollectionView.frame.size.height
                
                if contentYoffset > contentHeight - scrollViewHeight {
                    if self.fetchMore {
                        self.fetchNextData()
                        DEBUG_LOG(self.pageIndex)
                    }
                }
            }
            .disposed(by: disposeBag)
        
    }
 
    private func fetchNextData() {
        DEBUG_LOG(tempString)
        fetchMore = false
        pageIndex += 1
        inputTrigger.accept((word: tempString, page: pageIndex, isMine: searchTarget.rawValue))
    }

    private func prepareFolderCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = (view.frame.width - 47) / 2
        let height: CGFloat = 214
        layout.itemSize = CGSize(width: width, height: height)
        folderCollectionView.collectionViewLayout = layout
        folderCollectionView.contentInset = UIEdgeInsets(top: 24, left: 15, bottom: 50, right: 15)
        folderCollectionView.register(UINib(nibName: FolderCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: FolderCell.cellIdentifier)
    }
}
