//
//  AddLinkViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/17.
//
import UIKit
import Toast_Swift

enum EditPresetingStyle {
    case add
    case edit
}

final class AddLinkViewController: UIViewController {
    
    @IBOutlet private weak var linkTitleTextField: UITextField! // tag 1
    @IBOutlet private weak var linkURLTextField: UITextField! // tag 2
    @IBOutlet private weak var folderSelectionView: UIView!
    @IBOutlet private weak var folderPlaceHolderLabel: UILabel!
    @IBOutlet private weak var folderSelectionLabel: UILabel!
    @IBOutlet private weak var saveButtonView: UIView!
    
    private let addLinkViewModel: AddLinkViewModel = AddLinkViewModel()
    private let linkPresentaionService: LinkPresentaionService = LinkPresentaionService()
    
    public var isLinkUpdated: Bool = false
    var linkPresetingStyle: EditPresetingStyle = .add
    var link: FolderDetail.Link?
    
    var sourceFolderName: String? // edit 할 때 폴더가 바뀌었는지 파악함
    var sourceFolderIndex: Int?
    
    var destinationFolderName: String? // 사용자가 저장하려는 폴더
    var destinationFolderIndex: Int?
    
    var alertSucceedViewHandler: (() -> Void)? // test
    
    private var isButtonClicked: Bool = false
  
    override func viewDidLoad() {
        super.viewDidLoad()

        update()
        prepareFolderSelectionView() // 메인에서 클릭했을 떄에만
        prepareViewGesture()
        prepareSaveButtonView()
        prepareLinkTitleTextField()
        prepareLinkURLTextField()
    }
    
    private func update() {
        guard let destinationFolderName = destinationFolderName else { return }
        guard let destinationFolderIndex = destinationFolderIndex else { return }
        
        folderSelectionLabel.text = destinationFolderName
        folderSelectionLabel.isHidden = false
        folderPlaceHolderLabel.isHidden = true
        
        switch linkPresetingStyle {
        case .edit:
            guard let link = link else { return }
            self.linkTitleTextField.text = link.name
            self.linkURLTextField.text = link.url
            
            self.sourceFolderName = destinationFolderName
            self.sourceFolderIndex = destinationFolderIndex
        default:
            break
        }
    }
    
    private func prepareFolderSelectionView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(folderSelectionViewTapped))
        folderSelectionView.addGestureRecognizer(tapGesture)
        folderSelectionView.isUserInteractionEnabled = true
        
        folderSelectionView.layer.masksToBounds = true
        folderSelectionView.layer.cornerRadius = 8
        folderSelectionView.layer.borderColor = UIColor.linkMoaFolderSeletionBorderColor.cgColor
        folderSelectionView.layer.borderWidth = 1
    }
    
    private func prepareSaveButtonView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped))
        saveButtonView.addGestureRecognizer(tapGesture)
        saveButtonView.isUserInteractionEnabled = true
        
        saveButtonView.layer.masksToBounds = true
        saveButtonView.layer.cornerRadius = 8
    }
    
    private func prepareLinkTitleTextField() {
        linkTitleTextField.delegate = self
        linkTitleTextField.tag = 1
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: linkTitleTextField.frame.height))
        linkTitleTextField.leftView = paddingView
        linkTitleTextField.leftViewMode = .always
        
        linkTitleTextField.attributedPlaceholder = NSAttributedString(string: "네이버", attributes: [
            .foregroundColor: UIColor.placeholderText,
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        linkTitleTextField.layer.masksToBounds = true
        linkTitleTextField.layer.cornerRadius = 8
    }
    
    private func prepareLinkURLTextField() {
        linkURLTextField.delegate = self
        linkURLTextField.tag = 2
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: linkURLTextField.frame.height))
        linkURLTextField.leftView = paddingView
        linkURLTextField.leftViewMode = .always
        
        linkURLTextField.attributedPlaceholder = NSAttributedString(string: "https://www.naver.com", attributes: [
            .foregroundColor: UIColor.placeholderText,
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        linkURLTextField.layer.masksToBounds = true
        linkURLTextField.layer.cornerRadius = 8
    }
    
    private func prepareViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    private func fetchLink(name: String, url: String, sourceFolderIndex: Int, link: FolderDetail.Link) {
        view.makeToastActivity(ToastPosition.center)
        
        linkPresentaionService.fetchMetaDataURL(targetURLString: url, completionHandler: { [weak self] webMetaData in
            guard let self = self else { return }
            guard let webMetaData = webMetaData else {
                print("서버 에러")
                return
            }
            
            var params: [String: Any] = ["folderIdx": sourceFolderIndex,
                                          "linkName": name,
                                          "linkUrl": url
            ]
            
            if let favicon = webMetaData.faviconURLString {
                params["linkFaviconUrl"] = favicon
            } else {
                params["linkFaviconUrl"] = "-1"
            }
            
            if let image = webMetaData.webPreviewURLString {
                if image.isValidHttps() {
                    params["linkImageUrl"] = image
                } else {
                    let imageAddHttp = "http:" + image
                    
                    if imageAddHttp.isValidHttps() {
                        params["linkImageUrl"] = imageAddHttp
                    } else {
                        params["linkImageUrl"] = "-1"
                    }
                }
            } else {
                params["linkImageUrl"] = "-1"
            }
            
            DispatchQueue.main.async {
                self.addLinkViewModel.editLink(link: link.index, params: params, completionHandler: { result in
                    switch result {
                    case .success(let linkResponse):
                        if linkResponse.isSuccess {
                            self.view.hideToastActivity()
                            
                            self.dismiss(animated: true, completion: {
                                self.alertSucceedViewHandler?()
                            })
                        } else {
                            print("서버 에러")
                        }
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        })
    }
    
    private func moveLink(name: String, url: String, sourceFolderIndex: Int, destinationFolderIndex: Int, link: FolderDetail.Link) {
            // 다른 폴더에서 링크 수정 -> 자신 폴더에서 링크 삭제 후, 다른 폴더에 링크 추가
            view.makeToastActivity(ToastPosition.center)
            
            addLinkViewModel.deleteLink(link: link.index, completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let linkResponse):
                    if linkResponse.isSuccess {
                        self.linkPresentaionService.fetchMetaDataURL(targetURLString: url, completionHandler: { [weak self] webMetaData in
                            guard let self = self else { return }
                            guard let webMetaData = webMetaData else {
                                print("서버 에러")
                                return
                            }
                            
                            var params: [String: Any] = ["linkName": name,
                                                          "linkUrl": url
                            ]
                            
                            if let favicon = webMetaData.faviconURLString {
                                params["linkFaviconUrl"] = favicon
                            }
                            
                            if let image = webMetaData.webPreviewURLString {
                                if image.isValidHttps() {
                                    params["linkImageUrl"] = image
                                } else {
                                    let imageAddHttp = "http:" + image
                                    
                                    if imageAddHttp.isValidHttps() {
                                        params["linkImageUrl"] = imageAddHttp
                                    }
                                }
                            }
                            
                            self.addLinkViewModel.inputs.addLink(folder: destinationFolderIndex, params: params, completionHandler: { result in
                                switch result {
                                case .success(let linkResponse):
                                    if linkResponse.isSuccess {
                                        self.dismiss(animated: true, completion: {
                                            self.alertSucceedViewHandler?()
                                        })
                                    } else {
                                        print("서버 에러")
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            })
                        })
                    } else {
                        print("서버 에러 발생")
                    }
                case .failure(let error):
                    print(error)
                }
            })
    }
    
    private func addLink(linkName: String, url: String, folderIndex: Int) {
        isButtonClicked.toggle()
        view.makeToastActivity(ToastPosition.center)
        
        linkPresentaionService.fetchMetaDataURL(targetURLString: url, completionHandler: { [weak self] webMetaData in
            guard let self = self else { return }
            guard let webMetaData = webMetaData else {
                print("서버 에러")
                return
            }
            
            var params: [String: Any] = ["linkName": linkName,
                                          "linkUrl": url
            ]
            
            if let favicon = webMetaData.faviconURLString {
                    params["linkFaviconUrl"] = favicon
            }
            
            if let image = webMetaData.webPreviewURLString {
                if image.isValidHttps() {
                    params["linkImageUrl"] = image
                } else {
                    let imageAddHttp = "http:" + image
                    
                    if imageAddHttp.isValidHttps() {
                        params["linkImageUrl"] = imageAddHttp
                    }
                }
            }
            
            self.addLinkViewModel.inputs.addLink(folder: folderIndex, params: params, completionHandler: { result in
                switch result {
                case .success(let linkResponse):
                    if linkResponse.isSuccess {
                        self.dismiss(animated: true, completion: {
                            self.alertSucceedViewHandler?()
                        })
                    } else {
                        print("서버 에러")
                    }
                case .failure(let error):
                    print(error)
                }
            })
        })
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func folderSelectionViewTapped() {
        guard let folderSelectVC = FolderSelectViewController.storyboardInstance() else { return }
        
        folderSelectVC.selectHandler = { [weak self] folderName, folderIndex in
            guard let self = self else { return }
            self.destinationFolderName = folderName
            self.destinationFolderIndex = folderIndex
            self.update()
        }
        
        navigationController?.pushViewController(folderSelectVC, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard !isButtonClicked else { return }
        
        guard let name = linkTitleTextField.text, !name.isEmpty else {
            view.makeToast("링크 이름을 입력해주세요.", position: .top)
            return
        }
        
        guard name.count < 30 else {
            view.makeToast("링크 이름은 30자를 넘길 수 없습니다.", position: .top)
            return
        }
        
        guard let url = linkURLTextField.text, !url.isEmpty else {
            view.makeToast("링크 주소를 입력해주세요.", position: .top)
            return
        }
        
        guard url.isValidHttps() else {
            view.makeToast("올바른 링크 주소를 입력해주세요.", position: .top)
            return
        }
        
        guard let destinationFolderName = destinationFolderName, let destinationFolderIndex = destinationFolderIndex else {
            view.makeToast("저장할 폴더를 선택해주세요.", position: .top)
            return
        }
        
        switch linkPresetingStyle {
        case .add:
            addLink(linkName: name, url: url, folderIndex: destinationFolderIndex)
        case .edit:
            guard let sourceFolderIndex = sourceFolderIndex, let link = link else { return }
            view.makeToastActivity(ToastPosition.center)
            
            if sourceFolderIndex == destinationFolderIndex, sourceFolderName == destinationFolderName {
                fetchLink(name: name, url: url, sourceFolderIndex: sourceFolderIndex, link: link)
            } else {
                moveLink(name: name, url: url, sourceFolderIndex: sourceFolderIndex, destinationFolderIndex: destinationFolderIndex, link: link)
            }
        }
    }
    
    @IBAction func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension AddLinkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            textField.resignFirstResponder()
            linkURLTextField.becomeFirstResponder()
        case 2:
            textField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
}
