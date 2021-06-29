//
//  Observable.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/06.
//

import Foundation

public final class LMObservable<T> {
    typealias Observer = (T) -> Void
    
    var observer: Observer?
    
    var value: T {
        didSet {
            observer?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }
    
    func bind(observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
}
