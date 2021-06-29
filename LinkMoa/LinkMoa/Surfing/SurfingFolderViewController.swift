//
//  SavedFolderViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/06.
//

import UIKit
import RxSwift
import RxCocoa

enum SurfingFolderType {
    case topTen
    case liked
    case users
}

class SurfingFolderViewController: UIViewController {
    
    @IBOutlet private weak var folderCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    var surfingFolerType: SurfingFolderType = .topTen
    weak var homeNavigationController: HomeNavigationController?

    private let viewModel: SurfingFolderViewModel = SurfingFolderViewModel()
    private let disposeBag = DisposeBag()
    
    private lazy var inputs: SurfingFolderViewModel.Input = .init(
        fetchTopTenFolder: topTenTrigger.asSignal(),
        fetchLikedFolders: likedTrigger.asSignal(),
        fetchUsersFolders: usersTrigger.asSignal()
    )
    
    private lazy var outputs: SurfingFolderViewModel.Output = viewModel.transform(input: inputs)
    
    private let topTenTrigger = PublishRelay<Void>()
    private let likedTrigger = PublishRelay<(word: String?, page: Int)>()
    private let usersTrigger = PublishRelay<(user: Int, page: Int)>()

    var pageIndex: Int = 0
    var userIndex: Int = 0
    var userName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFolderCollectionView()
        prepareNavigationBar()
        prepareHeader()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch surfingFolerType {
        case .topTen:
            topTenTrigger.accept(())
        case .liked :
            likedTrigger.accept((word: nil, page: pageIndex))
        case .users:
            usersTrigger.accept((user: userIndex, page: pageIndex))
        }
    }
    
    private func bind() {
        switch surfingFolerType {
        case .topTen:
            break
        case .liked, .users:
            outputs.folders
                .map { $0.count.toAbbreviationString }
                .drive(countLabel.rx.text)
                .disposed(by: disposeBag)
        }
        
        outputs.folders
            .drive(folderCollectionView.rx.items(cellIdentifier: FolderCell.cellIdentifier, cellType: FolderCell.self)) { _, result, cell in
                cell.update(by: result)
            }
            .disposed(by: disposeBag)
        
        folderCollectionView.rx.modelSelected(IntegratedFolder.self)
            .bind(onNext: { [weak self] result in
                guard let self = self else { return }
                guard let vc = SurfingFolderDetailViewController.storyboardInstance() else { fatalError() }
                vc.homeNavigationController = self.homeNavigationController
                vc.folderIndex = result.folderIndex
                self.homeNavigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)

        outputs.errorMessage
            .emit { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            }
            .disposed(by: disposeBag)
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
    }
    
    private func prepareHeader() {
        switch surfingFolerType {
        case .topTen:
            titleLabel.text = "TOP 10 링크달"
            countLabel.isHidden = true
        case .liked:
            titleLabel.text = "찜한 링크달"
        case .users:
            titleLabel.text = userName
        }
    }

    private func prepareFolderCollectionView() {
        let nib = UINib(nibName: FolderCell.cellIdentifier, bundle: nil)
        folderCollectionView.register(nib, forCellWithReuseIdentifier: FolderCell.cellIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = (folderCollectionView.frame.width - 47) / 2
        let height: CGFloat = 214
        layout.itemSize = CGSize(width: width, height: height)
        
        folderCollectionView.collectionViewLayout = layout
        folderCollectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 50, right: 16)
    }
}
