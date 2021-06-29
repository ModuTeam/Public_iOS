//
//  UIImage+Grey.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/21.
//

import UIKit

public extension UIImage {
    var greyScale: UIImage? {
        guard let filter = CIFilter(name: "CIExposureAdjust"), let image = CIImage(image: self) else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(-0.5, forKey: kCIInputEVKey)
    
        guard let ciImage = filter.outputImage else { return nil }
        return UIImage(ciImage: ciImage)
    }
}
