//
//  MyPageViewController.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import UIKit
import MessageUI

class MyPageViewController: UIViewController, CustomAlert, BackgroundBlur {

    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var editNicknameButton: UIButton!
    @IBOutlet private weak var menuTableView: UITableView!
    
    private let viewModel: MyPageViewModel = MyPageViewModel()
    private var userInfo: Observable<[UserInfo.Result]> = Observable([])
    private var userIndex: Int = 0
    private let menus: [String] = ["FAQ", "건의&불편신고", "링크모아 브라우저 사용하기", "버전 정보", "오픈소스 라이센스 이용고지", "탈퇴하기"]

    private var tokenManaer = TokenManager()
    
    static func storyboardInstance() -> MyPageViewController? {
        let storyboard = UIStoryboard(name: MyPageViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
        }
        
        prepareMenuTableView()
        prepareNavigationBar()
        prepareNavigationItem()
        prepareLogoutButton()
        
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.inputs.fetchUserInfo()
    }

    private func bind() {
        viewModel.outputs.userInfo.bind { [weak self] results in
            guard let self = self else { return }
            self.userInfo.value = results
            if self.userInfo.value.count > 0 {
                self.nicknameLabel.text = self.userInfo.value[0].nickname
                    self.userIndex = self.userInfo.value[0].index
            }
        }
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
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
    
    private func composeMailVC() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            self.view.makeToast("메일 서비스를 사용할 수 없습니다.", duration: 1.0, position: .top)
        } else {
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["moduteamdev@gmail.com"])
            composeVC.setSubject("LinkMoa feedback")
            composeVC.setMessageBody("iOS version: \(Constant.iOSVersion!), App version: \(Constant.appVersion!).", isHTML: false)
            
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    private func deleteAccount() {
        
        self.fadeInBackgroundViewAnimation()
        self.alertReconfirmRequestView(type: .deleteAccount, animationHandler: {
            self.fadeOutBackgroundViewAnimation()
        },
        completeHandler: {
            DEBUG_LOG("탈퇴하기")
            self.fadeOutBackgroundViewAnimation()
            self.viewModel.inputs.deleteAccount(index: self.userIndex, completionHandler: {
                self.fadeInBackgroundViewAnimation()
                self.moveLoginVC()
                self.tokenManaer.jwtToken = nil
                self.fadeOutBackgroundViewAnimation()
                
            })
        })
    }
    
    private func moveLoginVC() {
        guard let LoginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? LoginViewController,
              let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        
        window.rootViewController = LoginVC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }

    @objc private func backNaviButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func browserSwitchTapped(_ sender: UISwitch) {
        tokenManaer.isUseSafari = sender.isOn == false ? true : false
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.fadeInBackgroundViewAnimation()
        self.alertReconfirmRequestView(type: .logout, animationHandler: {
            self.fadeOutBackgroundViewAnimation()
        },
        completeHandler: {
            self.fadeOutBackgroundViewAnimation()
            
            DEBUG_LOG("로그아웃 - 토큰삭제")
            self.moveLoginVC()
            self.tokenManaer.jwtToken = nil
        })
    }
    
    @IBAction func editNicknameButtonTapped() {
        guard let userNickname = userInfo.value.first?.nickname else { return }
        
        self.fadeInBackgroundViewAnimation()
        
        self.alertRemoveRequestView(type: .editNickname, folderName: userNickname, completeHandler: { [weak self] in
            guard let self = self else { return }
            self.fadeOutBackgroundViewAnimation()
        }, removeHandler: { [weak self] in
            guard let self = self else { return }
            self.viewModel.inputs.fetchUserInfo()
            
            self.fadeInBackgroundViewAnimation()
            self.alertSucceedView(type: .editNickname, completeHandler: {
                self.fadeOutBackgroundViewAnimation()
            })
        })
    }
}

extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myPageCell = tableView.dequeueReusableCell(withIdentifier: MyPageCell.cellIdentifier, for: indexPath) as? MyPageCell else { return UITableViewCell() }
        myPageCell.titleLabel.text = menus[indexPath.row]
        
        if indexPath.row == 2 {
            myPageCell.browserSwitch.isHidden = false
            let isUseSafari = tokenManaer.isUseSafari ?? false
            myPageCell.browserSwitch.isOn = isUseSafari == false ? true : false
            myPageCell.browserSwitch.addTarget(self, action: #selector(browserSwitchTapped(_:)), for: .valueChanged)
        }
        
        if indexPath.row == 3 {
            myPageCell.subTitleLabel.isHidden = false
            myPageCell.subTitleLabel.text = Constant.appVersion
        }

        return myPageCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            print("FAQ")
            guard let faqVC = FAQViewController.storyboardInstance() else { fatalError() }
//            self.navigationController?.pushViewController(faqVC, animated: true)
            faqVC.modalPresentationStyle = .fullScreen
            self.present(faqVC, animated: true, completion: nil)
        case 1:
            composeMailVC()
        case 2:
            print("버전정보")
        case 3:
            print("ㅇㅇ")
        case 4:
            guard let openSourceInfoVC = OpenSourceInfoViewController.storyboardInstance() else { return }
            
            openSourceInfoVC.modalPresentationStyle = .fullScreen
            present(openSourceInfoVC, animated: true)
        case 5:
            deleteAccount()
        default:
            print(indexPath.item)
        }
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            print(error)
        }
        switch result.rawValue {
        case 0:
            //cancelled
            print(result, result.rawValue)
            dismiss(animated: true) {
                self.view.makeToast("취소되었습니다.", duration: 1.0, position: .top)
            }
        case 1:
            //saved
            print(result, result.rawValue)
            dismiss(animated: true) {
                self.view.makeToast("메일이 저장되었습니다.", duration: 1.0, position: .top)
            }
        case 2:
            //sent
            print(result, result.rawValue)
            dismiss(animated: true) {
                self.view.makeToast("소중한 의견 감사합니다.", duration: 1.0, position: .top)
            }
        case 3:
            //failed
            print(result, result.rawValue)
            dismiss(animated: true) {
                self.view.makeToast("다시 시도해주세요.", duration: 1.0, position: .top)
            }
            
        default:
            print(result, result.rawValue)
        }
    }
}
