//
//  TopMenuCell.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/02.
//

import UIKit

final class TopMenuCell: UICollectionViewCell {
    
    static let cellIdentifier: String = "TopMenuCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override var isSelected: Bool {
        didSet {
            titleLabel.layer.opacity = isSelected ? 1 : 0.3
            titleLabel.textColor = isSelected ? .linkMoaBlackColor : .linkMoaGrayColor
        }
    }
}
