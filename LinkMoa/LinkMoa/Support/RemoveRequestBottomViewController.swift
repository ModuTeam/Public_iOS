//
//  RemoveRequestBottomViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/20.
//

import UIKit
import Toast_Swift

final class RemoveRequestBottomViewController: UIViewController {

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var backGroundView: UIView!
    @IBOutlet private weak var folderNameTextField: UITextField!
    @IBOutlet private weak var deleteButtonView: UIView!
    @IBOutlet private weak var bottomSpacingLayout: NSLayoutConstraint!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var buttonLabel: UILabel!
    
    private let myScallopManager: MyScallopManager = MyScallopManager()
    
    var folderName: String?
    var completionHandler: (() -> ())?
    var removeHandler: (() -> ())?
    var removeRequest: RemoveRequest = .removeFolder
    
    static func storyboardInstance() -> RemoveRequestBottomViewController? {
        let storyboard = UIStoryboard(name: RemoveRequestBottomViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        prepareBackGroundView()
        prepareBottomViewGesture()
        prepareDeleteButtonView()
        prepareFolderNameTextField()
        prepareTitleLabels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareBottomViewRoundConer()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }

    private func prepareTitleLabels() {
        switch removeRequest {
        case .editNickname:
            folderNameTextField.text = folderName
            titleLabel.text = "닉네임 변경"
            subTitleLabel.text = "변경하려는 닉네임을 입력해주세요."
            buttonLabel.text = "닉네임 변경"
        default:
            if let name = folderName {
                let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
                let firstString = NSMutableAttributedString(string: "삭제를 원하시면 ")
                let secondString = NSAttributedString(string: "\(name)", attributes: secondAttributes)
                let thirdString = NSAttributedString(string: "을 입력하세요.")
                
                firstString.append(secondString)
                firstString.append(thirdString)
                subTitleLabel.attributedText = firstString
            }
        }
    }
    
    private func prepareFolderNameTextField() {
        
        folderNameTextField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: folderNameTextField.frame.height))
        folderNameTextField.leftView = paddingView
        folderNameTextField.leftViewMode = .always

        folderNameTextField.layer.masksToBounds = true
        folderNameTextField.layer.cornerRadius = 8
        
        if let folderName = folderName {
            folderNameTextField.attributedPlaceholder = NSAttributedString(string: folderName, attributes: [
                .foregroundColor: UIColor.linkMoaPlaceholderColor,
                .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
            ])
        }
    }
    
    private func prepareDeleteButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteButtonViewTapped))
        deleteButtonView.addGestureRecognizer(tapGesture)
        deleteButtonView.isUserInteractionEnabled = true
        
        deleteButtonView.layer.masksToBounds = true
        deleteButtonView.layer.cornerRadius = 8
        deleteButtonView.layer.borderWidth = 1
        deleteButtonView.layer.borderColor = UIColor.linkMoaRedColor.cgColor
    }
    
    private func prepareBottomViewRoundConer() {
        bottomView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        bottomView.clipsToBounds = true
    }
    
    private func prepareBottomViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bottomViewTapped))
        tapGesture.cancelsTouchesInView = false
        bottomView.addGestureRecognizer(tapGesture)
        bottomView.isUserInteractionEnabled = true
    }
    
    private func prepareBackGroundView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        backGroundView.addGestureRecognizer(tapGesture)
        backGroundView.isUserInteractionEnabled = true
    }
    
    @objc private func deleteButtonViewTapped() {
        switch removeRequest {
        case .removeFolder:
            guard let folderName = folderName, let text = folderNameTextField.text else { return }
            
            if folderName != text {
                view.makeToast("올바른 폴더 이름을 입력해주세요.", position: .top)
                return
            } else {
                self.completionHandler?()
                
                dismiss(animated: true, completion: {
                    self.removeHandler?()
                })
            }
        case .editNickname:
            guard let nickname = folderNameTextField.text else { return }
            
            myScallopManager.patchUserInformation(params: ["userNickname": nickname], completion: { [weak self] response in
                guard let self = self else { return }
                
                switch response {
                case .success(let result):
                    if result.isSuccess, result.code == 1000 {
                        self.completionHandler?()
                        
                        self.dismiss(animated: true, completion: {
                            self.removeHandler?()
                        })
                    } else {
                        self.view.makeToast("이미 사용중인 닉네임입니다.", position: .top)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    @objc private func backgroundViewTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func bottomViewTapped() {
        folderNameTextField.resignFirstResponder()
    }
        
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomSpacingLayout.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomSpacingLayout.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func dismissButtonTapped() {
        completionHandler?()
        dismiss(animated: true, completion: nil)
    }
}

extension RemoveRequestBottomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
