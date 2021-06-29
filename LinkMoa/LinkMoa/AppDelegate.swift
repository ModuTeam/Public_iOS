//
//  AppDelegate.swift
//  LinkMoa
//
//  Created by won heo on 2021/01/28.
//

import UIKit

#if !FAT_FRAMEWORK_NOT_AVAILABLE
import GoogleSignIn
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        #if !FAT_FRAMEWORK_NOT_AVAILABLE
        GIDSignIn.sharedInstance().clientID = "69180131901-pqse3nodhsihmtkaqtdc82uen5d29pnd.apps.googleusercontent.com"
        #endif

        Thread.sleep(forTimeInterval: 2)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
