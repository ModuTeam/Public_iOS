//
//  ShareViewController.swift
//  LinkMoaShareExtension
//
//  Created by won heo on 2021/02/10.
//
import UIKit
import Social
import MobileCoreServices
import Toast_Swift

class ShareViewController: UIViewController, CustomAlert, BackgroundBlur {

    @IBOutlet private weak var linkTitleTextField: UITextField! // tag 1
    @IBOutlet private weak var linkURLTextField: UITextField! // tag 2
    @IBOutlet private weak var folderSelectionView: UIView!
    @IBOutlet private weak var folderPlaceHolderLabel: UILabel!
    @IBOutlet private weak var folderSelectionLabel: UILabel!
    @IBOutlet private weak var saveButtonView: UIView!

    private let linkPresentaionService: LinkPresentaionService = LinkPresentaionService()
    private let shareViewModel: ShareViewModel = ShareViewModel()

    private var blurVC: BackgroundBlur? {
        return navigationController as? BackgroundBlur
    }
    
    private var urlString: String = "" {
        didSet {
            self.linkURLTextField.text = urlString
            
            linkPresentaionService.fetchTitle(urlString: urlString, completionHandler: { title in
                DispatchQueue.main.async {
                    self.linkTitleTextField.text = String(title?.prefix(30) ?? "")
                }
            })
        }
    }
    
    private var isButtonClicked: Bool = false
    private var destinationFolderName: String? // 사용자가 저장하려는 폴더
    private var destinationFolderIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchShareURL()
        prepareFolderSelectionView()
        prepareSaveButtonView()
        prepareLinkTitleTextField()
        prepareLinkURLTextField()
        prepareViewGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func fetchShareURL() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            DispatchQueue.main.async {
                                self.urlString = shareURL.absoluteString ?? ""
                            }
                        }
                    })
                }
            }
        }
    }

    private func prepareViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }
    
    private func prepareFolderSelectionView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(folderSelectionViewTapped))
        folderSelectionView.addGestureRecognizer(tapGesture)
        folderSelectionView.isUserInteractionEnabled = true
        
        folderSelectionView.layer.masksToBounds = true
        folderSelectionView.layer.cornerRadius = 8
        folderSelectionView.layer.borderColor = UIColor(rgb: 0xbcbdbe).cgColor
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
        linkTitleTextField.tag = 1
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: linkTitleTextField.frame.height))
        linkTitleTextField.leftView = paddingView
        linkTitleTextField.leftViewMode = .always
        
        linkTitleTextField.attributedPlaceholder = NSAttributedString(string: "네이버", attributes: [
            .foregroundColor: UIColor(rgb: 0xbdbdbd),
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        linkTitleTextField.layer.masksToBounds = true
        linkTitleTextField.layer.cornerRadius = 8
    }
    
    private func prepareLinkURLTextField() {
        linkURLTextField.tag = 2
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: linkURLTextField.frame.height))
        linkURLTextField.leftView = paddingView
        linkURLTextField.leftViewMode = .always
        
        linkURLTextField.attributedPlaceholder = NSAttributedString(string: "https://www.naver.com", attributes: [
            .foregroundColor: UIColor(rgb: 0xbdbdbd),
            .font: UIFont(name: "NotoSansCJKkr-Regular", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        ])
        
        linkURLTextField.layer.masksToBounds = true
        linkURLTextField.layer.cornerRadius = 8
    }
    
    func hideExtensionWithCompletionHandler(completionHandler: @escaping () -> Void) {
        UIView.animate(withDuration: 0.20, animations: { () -> Void in
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        }, completion: { _ in
            completionHandler()
        })
    }
    
    @objc private func folderSelectionViewTapped() {
        guard let folderSelectVc = ShareFolderSelectionViewController.storyboardInstance() else { return }

        folderSelectVc.selectHandler = { [weak self] (folderName, folderIndex) in
            guard let self = self else { return }
            self.destinationFolderName = folderName
            self.destinationFolderIndex = folderIndex
            
            self.folderSelectionLabel.text = folderName
            self.folderSelectionLabel.isHidden = false
            self.folderPlaceHolderLabel.isHidden = true
        }
        
        navigationController?.pushViewController(folderSelectVc, animated: true)
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
        guard !isButtonClicked else { return }
        
        guard let name = linkTitleTextField.text, !name.isEmpty else {
            view.makeToast("링크 이름을 입력해주세요.", position: .top)
            return
        }
        
        guard name.count <= 30 else {
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
        
        guard destinationFolderName != nil, let destinationFolderIndex = destinationFolderIndex else {
            view.makeToast("저장할 폴더를 선택해주세요.", position: .top)
            return
        }
        
        isButtonClicked.toggle()
        view.makeToastActivity(ToastPosition.center)
        
        linkPresentaionService.fetchMetaDataURL(targetURLString: url, completionHandler: { [weak self] webMetaData in
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
            
            self.shareViewModel.inputs.addLink(folder: destinationFolderIndex, params: params, completionHandler: { result in
                switch result {
                case .success(let linkResponse):
                    if linkResponse.isSuccess {
                        self.view.hideToastActivity()
                        self.presentImageAlertView { [weak self] in
                            guard let self = self else { return }
                            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
                        }
                    } else {
                        print("서버 에러")
                    }
                case .failure(let error):
                    print(error)
                }
            })
        })
    }
    
    @IBAction func dismissButtonTapped() {
        hideExtensionWithCompletionHandler(completionHandler: {
            self.extensionContext!.cancelRequest(withError: NSError())
        })
    }
}
