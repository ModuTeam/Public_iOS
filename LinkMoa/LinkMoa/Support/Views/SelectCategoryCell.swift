//
//  SelectCategoryCell.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/17.
//

import UIKit

class SelectCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    static let cellIdentifier: String = "SelectCategoryCell"
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                titleLabel.textColor = UIColor.white
                backgroundColor = UIColor.linkMoaDarkBlueColor
            } else {
                titleLabel.textColor = UIColor.linkMoaCategoryOptionBlackColor
                backgroundColor = UIColor.linkMoaOptionBackgroundColor
            }
        }
    }
    
    var isSelectedCell: Bool = false {
        didSet {
            if self.isSelectedCell {
                titleLabel.textColor = UIColor.white
                backgroundColor = UIColor.linkMoaDarkBlueColor
            } else {
                titleLabel.textColor = UIColor.linkMoaCategoryOptionBlackColor
                backgroundColor = UIColor.linkMoaOptionBackgroundColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareLayer()
    }
    
    private func prepareLayer() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
}
