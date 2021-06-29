//
//  UIVIewController+RxViewLifeSycle.swift
//  LinkMoa
//
//  Created by won heo on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

extension RxSwift.Reactive where Base: UIViewController {
    public var viewDidLoad: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewDidLoad))
            .map { $0.first as? Bool ?? false }
    }
    
    public var viewWillAppear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }
}
