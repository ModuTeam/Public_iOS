//
//  MyPageCell.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/16.
//

import UIKit

class MyPageCell: UITableViewCell {
    
    static let cellIdentifier: String = "MyPageCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var browserSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subTitleLabel.isHidden = true
    }
}
