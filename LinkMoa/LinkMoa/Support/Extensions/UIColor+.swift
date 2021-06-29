//
//  UIColor+.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/07.
//

import UIKit

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    class var linkMoaBlackColor: UIColor {
        return UIColor(rgb: 0x485153)
    }
    
    class var linkMoaGrayColor: UIColor {
        return UIColor(rgb: 0x4B4B4B)
    }
    
    class var linkMoaDarkBlueColor: UIColor {
        return UIColor(rgb: 0x364788)
    }
    
    class var linkMoaDarkRedColor: UIColor {
        return UIColor(rgb: 0xe4746e)
    }
    
    class var linkMoaRedColor: UIColor {
        return UIColor(rgb: 0xef534b)
    }
    
    class var linkMoaOptionBackgroundColor: UIColor {
        return UIColor(rgb: 0xeeeeee)
    }
    
    class var linkMoaOptionTextColor: UIColor {
        return UIColor(rgb: 0xc0c0c0)
    }
    
    class var linkMoaPlaceholderColor: UIColor {
        return UIColor(rgb: 0xbdbdbd)
    }
    
    class var linkMoaFolderSeletionBorderColor: UIColor {
        return UIColor(rgb: 0xbcbdbe)
    }
    
    class var linkMoaFolderCountGrayColor: UIColor {
        return UIColor(rgb: 0x909090)
    }
    
    class var linkMoaCategoryOptionBlackColor: UIColor {
        return UIColor(rgb: 0x5c5c5c)
    }
}
