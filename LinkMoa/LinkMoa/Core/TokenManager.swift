//
//  TokenManager.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/08.
//

import Foundation


public enum TokenType {
    case jwt
    case userIndex
    case browser
}

extension TokenType {
    var name: String {
        switch self {
        case .jwt:
            return "jwtToken"
        case .userIndex:
            return "userIndex"
        case .browser:
            return "browser"
        }
    }
}

public struct TokenManager {
    
    init() {
        guard let userDefault = UserDefaults(suiteName: "group.com.makeus.linkMoa") else { fatalError() }
        self.userDefault = userDefault
    }
    
    private var userDefault: UserDefaults
    
    var jwtToken: String? {
        get {
            switch Constant.serviceType {
            case .dev:
                return Constant.devTestToken
            case .product:
                return userDefault.string(forKey: TokenType.jwt.name)
            }
        }
        set {
            userDefault.setValue(newValue, forKey: TokenType.jwt.name)
        }
    }
    
    var userIndex: Int? {
        get {
            return Int(userDefault.integer(forKey: TokenType.userIndex.name))
        }
        set {
            userDefault.setValue(newValue, forKey: TokenType.userIndex.name)
        }
    }
    
    var isUseSafari: Bool? {
        get {
            return userDefault.bool(forKey: TokenType.browser.name)
        }
        set {
            return userDefault.setValue(newValue, forKey: TokenType.browser.name)
        }
    }
}
