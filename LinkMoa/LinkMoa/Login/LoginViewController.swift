//
//  LoginViewController.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/08.
//

import UIKit
import Lottie
import AuthenticationServices

#if !FAT_FRAMEWORK_NOT_AVAILABLE
import GoogleSignIn
#endif

final class LoginViewController: UIViewController {

    @IBOutlet private weak var googleLoginButtonView: UIView!
    @IBOutlet private weak var appleLoginStackView: UIStackView!
    @IBOutlet private weak var animationBaseView: UIView!
    @IBOutlet private weak var privateRuleLabel: UILabel!
    @IBOutlet private weak var useRuleLabel: UILabel!
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "garibi")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 375)
        animationView.loopMode = .loop
        return animationView
    }()
    
    private let surfingManager: SurfingManager = SurfingManager()
    private let loginViewModel = LoginViewModel()
    private var tokenManager = TokenManager()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static func storyboardInstance() -> LoginViewController? {
        let storyboard = UIStoryboard(name: LoginViewController.storyboardName(), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareAppleLoginStackView()
        prepareGoogleLoginView()
        prepareRuleLabels()
        prepareAnimationView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(restartAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.play()
    }
    
    private func prepareAppleLoginStackView() {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        appleLoginStackView.addArrangedSubview(button)
        appleLoginStackView.layer.masksToBounds = true
        appleLoginStackView.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(appleLoginStackViewTapped))
        appleLoginStackView.addGestureRecognizer(tapGesture)
        appleLoginStackView.isUserInteractionEnabled = true
    }

    private func prepareRuleLabels() {
        let privateTapGesture = UITapGestureRecognizer(target: self, action: #selector(ruleLabelsTapped(_:)))
        privateRuleLabel.addGestureRecognizer(privateTapGesture)
        privateRuleLabel.isUserInteractionEnabled = true
        
        let privateUnderlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let privateUnderlineAttributedString = NSAttributedString(string: "개인정보처리방침", attributes: privateUnderlineAttribute)
        privateRuleLabel.attributedText = privateUnderlineAttributedString
        
        let useTapGesture = UITapGestureRecognizer(target: self, action: #selector(ruleLabelsTapped(_:)))
        useRuleLabel.addGestureRecognizer(useTapGesture)
        useRuleLabel.isUserInteractionEnabled = true
        
        let useUnderlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let useUnderlineAttributedString = NSAttributedString(string: "이용약관", attributes: useUnderlineAttribute)
        useRuleLabel.attributedText = useUnderlineAttributedString
    }

    private func prepareAnimationView() {
        animationBaseView.addSubview(animationView)
    }
    
    private func prepareGoogleLoginView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startButtonTapped))
        googleLoginButtonView.addGestureRecognizer(tapGesture)
        googleLoginButtonView.isUserInteractionEnabled = true
        
        googleLoginButtonView.layer.masksToBounds = true
        googleLoginButtonView.layer.cornerRadius = 8
        
        #if !FAT_FRAMEWORK_NOT_AVAILABLE
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        #endif
    }
    
    @objc private func restartAnimation() {
        animationView.play()
    }
    
    @objc private func startButtonTapped() {
        #if !FAT_FRAMEWORK_NOT_AVAILABLE
        GIDSignIn.sharedInstance().signIn()
        #endif
    }
    
    private func moveHomeVC() {
        guard let homeVC = HomeViewController.storyboardInstance(),
              let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        
        let homeNC = HomeNavigationController(rootViewController: homeVC)
        
        window.rootViewController = homeNC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    private func moveRegisterVC() {
        guard let registerVC = RegisterNicknameViewController.storyboardInstance(),
              let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        
        let registerNC = RegisterNavigationController(rootViewController: registerVC)
        
        window.rootViewController = registerNC
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    @objc private func appleLoginStackViewTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self as ASAuthorizationControllerDelegate
        controller.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }
    
    @objc private func ruleLabelsTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }

        switch tag {
        case 1:
            let url = "https://www.notion.so/f87acd8339a8480cb79e0c4b06a6cc7e"
            
            if let url = URL(string: url) {
                UIApplication.shared.open(url, options: [:])
            }
            
        case 2:
            let url = "https://www.notion.so/f911dec4a02b4286a0aa0f0794afd1f4"
            
            if let url = URL(string: url) {
                UIApplication.shared.open(url, options: [:])
            }
        default:
            break
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {}
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = credential.identityToken,
           let authorizationCodeData = credential.authorizationCode,
           let identityToken = String(data: identityTokenData, encoding: .utf8),
           let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) {
            
            var name: String = "익명"
            
            if let familyName = credential.fullName?.familyName, let givenName = credential.fullName?.givenName {
                name = "\(familyName) \(givenName)"
            }
            
            loginViewModel.inputs.appleLogin(authCode: authorizationCode, handler: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    guard let result = response.result else {
                        print("LoginVC - result error")
                        return
                    }
                    
                    self.tokenManager.jwtToken = result.jwt
                    
                    guard let userIndex = response.result?.userIndex else {
                        print("LoginVC - userIndex error")
                        return
                    }
                    
                    self.tokenManager.userIndex = userIndex
                    
                    self.surfingManager.fetchUserInfo(completion: { response in
                        switch response {
                        case .success(let userInfo):
                            if let info = userInfo.result.first, info.categoryIndex != -1 { // [홈 화면] -> 회원, 정보까지 입력된 상태
                                self.moveHomeVC()
                            } else { // [회원가입 화면] -> 회원이지만, 정보 입력이 필요한 상태
                                self.moveRegisterVC()
                            }
                        case .failure(let error):
                            break
                        }
                    })
                    
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}

#if !FAT_FRAMEWORK_NOT_AVAILABLE
extension LoginViewController: GIDSignInDelegate {
    // 연동을 시도 했을때 불러오는 메소드
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        guard let accessToken = user.authentication.accessToken else {
            print("user token is nil")
            return
        }
        
        loginViewModel.inputs.googleLogin(accessToken: accessToken, handler: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let result = response.result else {
                    print("LoginVC - result error")
                    return
                }
                print("google login ->", result)
                self.tokenManager.jwtToken = result.jwt
                
                guard let userIndex = response.result?.userIndex else {
                    print("LoginVC - userIndex error")
                    return
                }
                
                self.tokenManager.userIndex = userIndex
                
                self.surfingManager.fetchUserInfo(completion: { response in
                    switch response {
                    case .success(let userInfo):
                        if let info = userInfo.result.first, info.categoryIndex != -1 { // [홈 화면] -> 회원, 정보까지 입력된 상태
                            self.moveHomeVC()
                        } else { // [회원가입 화면] -> 회원이지만, 정보 입력이 필요한 상태
                            self.moveRegisterVC()
                        }
                    case .failure(let error):
                        break
                    }
                })
            case .failure(let error):
                print(error)
            }
        })
    }
    
    // 구글 로그인 연동 해제했을때 불러오는 메소드
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Disconnect")
    }
}
#endif
