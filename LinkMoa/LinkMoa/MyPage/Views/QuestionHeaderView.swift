//
//  QuestionHeaderView.swift
//  LinkMoa
//
//  Created by Beomcheol Kwon on 2021/03/19.
//

import UIKit

class QuestionHeaderView: UITableViewHeaderFooterView {
    
    static let headerIdentifier = "QuestionHeaderView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var sectionButton: UIButton!

}
