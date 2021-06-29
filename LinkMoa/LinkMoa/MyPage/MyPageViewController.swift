//
//  MyPageViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa

class MyPageViewController: UIViewController, CustomAlert, BackgroundBlur {
    
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var editNicknameButton: UIButton!
    @IBOutlet private weak var menuTableView: UITableView!
    
    private lazy var composeVC: MFMailComposeViewController = {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        vc.setToRecipients(["moduteamdev@gmail.com"])
        vc.setSubject("LinkMoa feedback")
        vc.setMessageBody("iOS version: \(Constant.iOSVersion!), App version: \(Constant.appVersion!).", isHTML: false)
        return vc
    }()
    
    private let viewModel: MyPageViewModel = MyPageViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    
    private lazy var inputs: MyPageViewModel.Input = .init(fetchUserNickname: rx.viewWillAppear.map { _ in },
                                                           useSafariToggle: safariToggleAction.asObservable(),
                                                           changeUserNickName: changeNicknameAction.asObservable(),
                                                           logout: logoutAction.asObservable(),
                                                           deleteUser: deleteAction.asObserver())
    private lazy var outputs: MyPageViewModel.Output = viewModel.transform(input: inputs)
        
    // MARK: - Action
    private let changeNicknameAction = PublishSubject<String>()
    private let safariToggleAction = PublishSubject<Bool>()
    private let logoutAction = PublishSubject<Void>()
    private let deleteAction = PublishSubject<Void>()
    
    // MARK: - View Life Sycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
    
    // MARK: - Methods
    private func bind() {
        // bottomAlert
        outputs.bottomAlert
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.presentImageAlertView()
            })
            .disposed(by: disposeBag)
        
        // error
        outputs.error
            .drive(onNext: { [weak self] errorMessage in
                guard let self = self else { return }
                self.view.makeToast(errorMessage, position: .top)
            })
            .disposed(by: disposeBag)

        // nicknameLabel
        outputs.userNickName
            .drive(nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        // menuTableView
        outputs.settingMenus
            .drive(menuTableView.rx.items(cellIdentifier: MyPageCell.cellIdentifier)) { [weak self] (index: Int, title: String, cell: MyPageCell) -> Void in
                guard let self = self else { return }
                
                cell.titleLabel.text = title
                
                if index == 2 {
                    self.outputs.isUseSafari.drive(cell.browserSwitch.rx.isOn)
                        .disposed(by: self.disposeBag)
                    
                    cell.browserSwitch.rx.isOn
                        .bind(to: self.safariToggleAction)
                        .disposed(by: self.disposeBag)
                    
                    cell.browserSwitch.isHidden = false
                }
                
                if index == 3 {
                    cell.subTitleLabel.isHidden = false
                    cell.subTitleLabel.text = Constant.appVersion
                }
                
                if index == 5 {
                    cell.titleLabel.textColor = UIColor.linkMoaRedColor
                }
            }
            .disposed(by: disposeBag)
        
        menuTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath: IndexPath) -> Void in
                guard let self = self else { return }
                
                switch indexPath.item {
                case 0:
                    guard let faqVC = FAQViewController.storyboardInstance() else { fatalError() }
                    faqVC.modalPresentationStyle = .fullScreen
                    self.present(faqVC, animated: true, completion: nil)
                case 1:
                    self.composeMailVC()
                case 4:
                    guard let openSourceInfoVC = OpenSourceInfoViewController.storyboardInstance() else { return }
                    openSourceInfoVC.modalPresentationStyle = .fullScreen
                    self.present(openSourceInfoVC, animated: true)
                case 5:
                    self.deleteAccount()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // editNicknameButton
        editNicknameButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                self.presentTextRequestView(type: .editNickname, name: self.viewModel.nickName) { [weak self] (nickName: Any) in
                    guard let self = self else { return }
                    guard let nickName = nickName as? String else { return }
                    self.changeNicknameAction.onNext(nickName)
                }
            })
            .disposed(by: disposeBag)
        
        // logoutButton
        logoutButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.presentReconfirmView(type: .logout) {
                    self.logoutAction.onNext(())
                    self.moveLoginVC()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureUI() {
        prepareMenuTableView()
        prepareNavigationBar()
        prepareNavigationItem()
        prepareLogoutButton()
    }
    
    private func prepareLogoutButton() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "로그아웃", attributes: underlineAttribute)
        logoutButton.setAttributedTitle(underlineAttributedString, for: .normal)
    }
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -9, bottom: -3, right: 0))
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -9, bottom: -3, right: 0))
    }
    
    private func prepareNavigationItem() {
        let backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backNaviButtonTapped))
        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        backBarButtonItem.tintColor = .black
        
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func prepareMenuTableView() {
        let nib = UINib(nibName: MyPageCell.cellIdentifier, bundle: nil)
        menuTableView.register(nib, forCellReuseIdentifier: MyPageCell.cellIdentifier)
    }
    
    private func composeMailVC() {
        guard MFMailComposeViewController.canSendMail() else {
            print("Mail services are not available")
            self.view.makeToast("메일 서비스를 사용할 수 없습니다.", duration: 1.0, position: .top)
            return
        }
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    private func deleteAccount() {
        self.presentReconfirmView(type: .deleteAccount) { [weak self] in
            guard let self = self else { return }
            self.deleteAction.onNext(())
            self.moveLoginVC()
        }
    }
    
    private func moveLoginVC() {
        guard let LoginVC = LoginViewController.storyboardInstance(),
              let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        
        window.rootViewController = LoginVC
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    @objc private func backNaviButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        var message: String = ""
        
        switch result.rawValue {
        case 0:
            message = "취소되었습니다."
        case 1:
            message = "메일이 저장되었습니다."
        case 2:
            message = "소중한 의견 감사합니다."
        case 3:
            message = "다시 시도해주세요."
        default:
            print(result, result.rawValue)
        }
        
        dismiss(animated: true) {
            self.view.makeToast(message, duration: 1.0, position: .top)
        }
    }
}
