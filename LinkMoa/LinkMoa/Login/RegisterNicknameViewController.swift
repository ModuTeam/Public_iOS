//
//  RegisterNicknameViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/18.
//

import UIKit
import Toast_Swift

class RegisterNicknameViewController: UIViewController {

    @IBOutlet private weak var nicknameTextField: UITextField!
    @IBOutlet private weak var nicknameTextFieldBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nextButtonView: UIView!
    @IBOutlet private weak var nextButtonLabel: UILabel!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var currentProgressView: UIView!
    
    private let nicknameViewModel: NicknameViewModel = NicknameViewModel()
    
    private var isVaildNickname: Bool = false {
        didSet {
            if isVaildNickname {
                nextButtonLabel.textColor = UIColor.white
                nextButtonView.backgroundColor = UIColor.linkMoaDarkBlueColor
            } else {
                nextButtonLabel.textColor = UIColor.linkMoaOptionTextColor
                nextButtonView.backgroundColor = UIColor.linkMoaOptionBackgroundColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNextButtonView()
        prepareProgressViews()
        prepareNicknameTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nicknameTextField.becomeFirstResponder()
    }
    
    private func prepareNextButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonViewTapped))
        nextButtonView.isUserInteractionEnabled = false
        nextButtonView.addGestureRecognizer(tapGesture)
        nextButtonView.layer.masksToBounds = true
        nextButtonView.layer.cornerRadius = 8
    }
    
    private func prepareNicknameTextField() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: nicknameTextField.frame.height))
        nicknameTextField.leftView = paddingView
        nicknameTextField.leftViewMode = .always
        
        nicknameTextField.attributedPlaceholder = NSAttributedString(string: "닉네임을 입력하세요.", attributes: [
            .foregroundColor: UIColor.linkMoaPlaceholderColor,
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        nicknameTextField.layer.masksToBounds = true
        nicknameTextField.layer.cornerRadius = 8
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func prepareProgressViews() {
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 2
        currentProgressView.layer.masksToBounds = true
        currentProgressView.layer.cornerRadius = 2
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            nicknameTextFieldBottomLayoutConstraint.constant = keyboardHeight + 15
        }
    }
    
    @objc private func nextButtonViewTapped() {
        guard let registerCategoryVC = RegisterCategoryViewController.storyboardInstance() else { return }
        guard isVaildNickname else { return }
        guard let nickname = nicknameTextField.text else { return }
        
        nicknameViewModel.patchUserInformation(params: ["userNickname": nickname], completion: { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let result):
                if result.isSuccess, result.code == 1000 {
                    registerCategoryVC.nickName = nickname
                    self.navigationController?.pushViewController(registerCategoryVC, animated: true)
                } else {
                    self.view.makeToast("중복된 닉네임 입니다.", position: ToastPosition.top)
                }
            case .failure(let error):
                print(error)
                self.view.makeToast("서버에 오류가 있습니다.", position: ToastPosition.top)
            }
        })
    }
    
    @objc private func textFieldDidChange() {
        if let nickname = nicknameTextField.text, !nickname.isEmpty {
            isVaildNickname = true
            nextButtonView.isUserInteractionEnabled = true
        } else {
            isVaildNickname = false
            nextButtonView.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func removeButtonTapped() {
        nicknameTextField.text = ""
        isVaildNickname = false
    }
}
