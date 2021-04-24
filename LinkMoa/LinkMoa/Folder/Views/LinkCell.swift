//
//  LinkCell.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/17.
//

import UIKit
import Kingfisher

final class LinkCell: UICollectionViewCell {

    static let cellIdentifier: String = "LinkCell"

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet private weak var faviconImageView: UIImageView!
    @IBOutlet private(set) weak var editButton: UICustomTagButton!
    @IBOutlet private(set) weak var dotImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = false
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 20
    }
    
    func update(by link: FolderDetail.Link) {
        nameLabel.text = link.name
        urlLabel.text = link.url
        
        if let url = URL(string: link.faviconURL), link.faviconURL != "-1"  {
            faviconImageView.kf.setImage(with: url, placeholder: UIImage(named: "seashell"))
        }
    }
    
    //MARK:- Surfing
    func update(by link: SearchLink.Result) {
        nameLabel.text = link.name
        urlLabel.text = link.url
        
        if let url = URL(string: link.faviconURL), link.faviconURL != "-1" {
            
            faviconImageView.kf.setImage(with: url, placeholder: UIImage(named: "seashell"))
        }
    }
}
