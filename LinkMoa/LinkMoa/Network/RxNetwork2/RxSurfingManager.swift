//
//  RxSurfingManager.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/05/13.
//

import Foundation
import Moya
import RxSwift

protocol RxSurfingNetworkable {
    var provider: MoyaProvider<RxSurfingAPI> { get }
}

struct RxSurfingManager: RxSurfingNetworkable {
//         var provider: MoyaProvider<SurfingAPI> = MoyaProvider<SurfingAPI>(plugins: [NetworkLoggerPlugin()])
    var provider: MoyaProvider<RxSurfingAPI> = MoyaProvider<RxSurfingAPI>(plugins: [])
    var disposeBag = DisposeBag()
}
