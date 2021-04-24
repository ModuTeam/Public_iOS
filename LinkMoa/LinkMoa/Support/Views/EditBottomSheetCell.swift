//
//  EditBottomSheetCell.swift
//  LinkMoa
//
//  Created by won heo on 2021/03/01.
//

import UIKit

final class EditBottomSheetCell: UITableViewCell {

    static let cellIdentifier: String = "EditBottomSheetCell"

    @IBOutlet private(set) weak var sheetNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(by title: String) {
        sheetNameLabel.text = title
    }
    
}
