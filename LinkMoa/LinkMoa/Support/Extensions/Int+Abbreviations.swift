//
//  Int+Abbreviations.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/09.
//

import Foundation

extension Int {
    var toAbbreviationString: String {
        let number = Double(self)
        let thousand = number / 1000
        let tenThousand = number / 10000
        let hundredMillion = number / 100000000
        if number >= 100000000 {
            return "\(Int(hundredMillion))억"
        } else if number >= 100000 {
            return "\(Int(tenThousand))만"
        } else if tenThousand >= 1.1 {
            return "\(round(tenThousand*10)/10)만"
        } else if tenThousand >= 1.0 {
            return "\(Int(tenThousand))만"
        } else if thousand >= 1.1 {
            return "\(round(thousand*10)/10)천"
        } else if thousand >= 1.0 {
            return "\(Int(thousand))천"
        } else {
            return "\(self)"
        }
    }
}
