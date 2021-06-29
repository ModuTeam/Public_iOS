//
//  HomeFolderCellCell.swift
//  LinkMoa
//
//  Created by won heo on 2021/02/03.
//

import UIKit
import Kingfisher

final class FolderCell: UICollectionViewCell {
    
    static let cellIdentifier: String = "FolderCell"
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = webPreviewImageView.bounds
        return layer
    }()

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var webPreviewImageView: UIImageView!
    @IBOutlet private weak var lockImageView: UIImageView!
    @IBOutlet private(set) weak var editButton: UICustomTagButton!
    @IBOutlet weak var heartStackView: UIStackView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addGradientLayer()
        heartStackView.isHidden = true
    }
    
    override func prepareForReuse() {
        resetComponents()
    }
    
    private func resetComponents() {
        webPreviewImageView.image = nil
        lockImageView.isHidden = true
    }
    
    // MARK: - My
    func update(by folder: FolderList.Result, isSupportGif: Bool = true) {
        titleLabel.text = folder.name
        countLabel.text = String(folder.linkCount)
        
        let isShared = folder.folderType == "private" ? false : true
        
        if isShared {
            lockImageView.isHidden = true
        } else {
            lockImageView.isHidden = false
        }
        
        if isSupportGif == false, folder.imageURL.hasSuffix(".gif") {
            return
        }
        
        if let url = URL(string: folder.imageURL), folder.imageURL != "-1" {
            webPreviewImageView.kf.setImage(with: url)
        }
    }

    // MARK: - Surfing
    func update(by folder: IntegratedFolder) {
        prepareSurfingFolder()
        titleLabel.text = folder.folderName
        countLabel.text = folder.linkCount.toAbbreviationString
        likeCountLabel.text = folder.likeCount.toAbbreviationString
        if folder.likeStatus == 1 {
            heartImageView.image = UIImage(systemName: "heart.fill")
        } else {
            heartImageView.image = UIImage(systemName: "heart")
        }
        
        if let linkImageURL = folder.linkImageURL, let url = URL(string: linkImageURL), linkImageURL != "-1" {
            webPreviewImageView.kf.setImage(with: url)
        }
    }
    
    func prepareSurfingFolder() {
        lockImageView.isHidden = true
        gradientLayer.isHidden = false
        heartStackView.isHidden = false
        editImageView.isHidden = true
    }
    
    func addGradientLayer() {
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let screenSize: CGFloat = UIScreen.main.bounds.width
        
        webPreviewImageView.frame.size.width = (screenSize - 16 * 3) / 2

        gradientLayer.frame = webPreviewImageView.bounds
        gradientLayer.mask = shapeLayer
        gradientLayer.colors = [UIColor.init(rgb: 0x303030).withAlphaComponent(0.4).cgColor, UIColor.white.withAlphaComponent(0.4).cgColor]
        
        let path = UIBezierPath(roundedRect: webPreviewImageView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        shapeLayer.path = path.cgPath
        
        webPreviewImageView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.isHidden = true
    }
}
