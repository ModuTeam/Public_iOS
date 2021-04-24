//
//  Constant.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/17.
//

import Foundation
import UIKit

struct Constant {
    
    enum ServiceType {
        case product
        case dev
    }
    
    struct FAQ {
        let question : String
        let answer : String
    }
    
    // 배포 / 테스트 버전 결정하는 값
    static let serviceType: ServiceType = .product

    static let pageLimit: Int = 20
    
    static let faqData: [FAQ] = [
        FAQ(question: "링크달과 가리비가 뭔가요?", answer: "가리비는 인터넷 링크이며, 링크달은 링크를 저장하는 폴더입니다."),
        FAQ(question: "링크달을 비공개로 해놓으면 다른 사람들은 볼 수 없나요?", answer: "비공개인 링크달은 다른 유저에게 보이지 않습니다."),
        FAQ(question: "링크달 추가는 어떻게 하나요?", answer: "메인화면 우측 하단의 '+' 버튼을 눌러 링크달을 추가할 수 있습니다."),
        FAQ(question: "가리비 추가는 어떻게 하나요?", answer: "메인화면 우측 하단의 '+' 버튼을 눌러 가리비를 추가할 수 있습니다. 또한, 사파리에서 공유 버튼을 눌러서 추가할 수도 있습니다."),
        FAQ(question: "링크달 공유는 어떻게 하나요?", answer: "공유할 링크달에 들어간 후 오른쪽 상단에 있는 메뉴 버튼을 눌러서 공유할 수 있습니다."),
        FAQ(question: "링크달 신고는 어떻게 하나요?", answer: "신고할 링크달에 들어간 후 오른쪽 상단에 있는 메뉴 버튼을 눌러서 신고할 수 있습니다. 신고된 링크달은 관리자의 판단에 하에 경고 없이 삭제될 수 있습니다."),
        FAQ(question: "검색은 어떻게 하나요?", answer: "나의 링크달에서는 내가 만든 링크달만 검색할 수 있습니다. 서핑하기에서는 모든 사용자가 공개한 링크달을 검색할 수 있습니다."),
        FAQ(question: "실수로 링크달을 삭제했습니다. 데이터를 복원할 수 있나요?", answer: "한 번 삭제한 링크달과 가리비는 복구할 수 없습니다."),
        FAQ(question: "회원탈퇴를 하면 데이터는 어떻게 되나요?", answer: "회원 탈퇴 직전의 모든 데이터는 서버에 저장되며, 탈퇴 후에는 수정하거나 삭제가 불가능합니다. 재가입 후에도 기존 데이터를 수정하실 수 없으니 탈퇴 전 데이터 정리를 꼭 하시길 바랍니다.")
    ]
    
    static var appVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
        return version
    }
    
    static var iOSVersion: String? {
        let os = ProcessInfo().operatingSystemVersion
        let iOSVersion = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        return iOSVersion
    }

    static let devTestToken: String = "    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWR4Ijo0MSwiaWF0IjoxNjE2NDY2NDY1LCJleHAiOjE2NDgwMDI0NjUsInN1YiI6InVzZXJJbmZvIn0.1-CZ0p7iNvClZImkNaFRrkvBtHEcqL-68rBTk8YDgxw"
    
    static let defaultImageURL: String = "https://i.imgur.com/NnjvaEe.png"
}
