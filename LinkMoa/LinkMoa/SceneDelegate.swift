//
//  SceneDelegate.swift
//  LinkMoa
//
//  Created by won heo on 2021/01/28.
//
import UIKit
import Toast_Swift

#if !FAT_FRAMEWORK_NOT_AVAILABLE
import GoogleSignIn
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        DEBUG_LOG("")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let loginVC = LoginViewController.storyboardInstance() else { return }
        guard let registerNicknameVC = RegisterNicknameViewController.storyboardInstance() else { return }
        guard let homeVC = HomeViewController.storyboardInstance() else { return }
        guard let splashVC = SplashViewController.storyboardInstance() else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let tokenManager: TokenManager = TokenManager()
        let surfingManager: SurfingManager = SurfingManager()
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        self.window = window
        
        if tokenManager.jwtToken != nil {
            surfingManager.fetchUserInfo(completion: { response in
                switch response {
                case .success(let userInfo):
                    if let info = userInfo.result.first, info.categoryIndex != -1 { // [홈 화면] -> 회원, 정보까지 입력된 상태
                        let homeNC = HomeNavigationController(rootViewController: homeVC)
                        homeVC.navigationItem.backButtonTitle = ""
                        window.rootViewController = homeNC

                        // URL접근(위젯)
                        if let scheme = connectionOptions.urlContexts.first?.url.scheme {
                            if scheme.contains("linkmoa") {
                                guard let homeNC = window.rootViewController as? HomeNavigationController else { return }
                                
                                guard let folderVC = SurfingFolderDetailViewController.storyboardInstance() else { return }
                                
                                let host = connectionOptions.urlContexts.first?.url.host ?? "0"
                                folderVC.folderIndex = Int(host) ?? 0
                                folderVC.homeNavigationController = homeNC
                                
                                homeNC.pushViewController(folderVC, animated: false)
                            }
                        }

                    } else { // [회원가입 화면] -> 회원이지만, 정보 입력이 필요한 상태
                        window.rootViewController = RegisterNavigationController(rootViewController: registerNicknameVC)
                    }
                case .failure(let error): // [로그인 화면] -> 서버 에러 발생
                    print(error)
                    window.rootViewController = loginVC
                    DEBUG_LOG(error)
                }
            })
        } else { // [로그인 화면] -> JWT 토큰 없음
            window.rootViewController = loginVC
        }
        
        ToastManager.shared.style.activityBackgroundColor = .clear
        ToastManager.shared.style.activityIndicatorColor = .linkMoaDarkBlueColor
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let scheme = URLContexts.first?.url.scheme else { return }
        
        if scheme.contains("com.googleusercontent.apps") {
            #if !FAT_FRAMEWORK_NOT_AVAILABLE
            GIDSignIn.sharedInstance().handle(URLContexts.first?.url)
            #endif
        }
        
        if scheme.contains("linkmoa") {
            guard let homeNC = window?.rootViewController as? HomeNavigationController else { return }
            
            guard let folderVC = SurfingFolderDetailViewController.storyboardInstance() else { return }
            
            let host = URLContexts.first?.url.host ?? "0"
            folderVC.folderIndex = Int(host) ?? 0
            folderVC.homeNavigationController = homeNC
        
            homeNC.dismiss(animated: false, completion: nil)
            homeNC.popToRootViewController(animated: false)
            homeNC.pushViewController(folderVC, animated: false)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
