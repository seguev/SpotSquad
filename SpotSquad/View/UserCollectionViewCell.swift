//
//  UserCollectionViewCell.swift
//  CoffeeFetch
//
//  Created by segev perets on 17/01/2023.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageIsLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var cellImage: UIImageView!
    
    func config (_ userName:String) {
        userLabel.text = userName
    }
    
    func updateImage (_ image:UIImage) {
        DispatchQueue.main.async {
            self.imageIsLoadingIndicator.stopAnimating()
            self.cellImage.isHidden = false
            self.cellImage.image = image
            
            let imageHeight = self.frame.height - self.userLabel.frame.height
            self.cellImage.frame = .init(x: 0, y: 0, width: imageHeight, height: imageHeight)
            self.cellImage.layer.cornerRadius = self.cellImage.frame.height / 2
            
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowRadius = 5
            self.layer.shadowOpacity = 0.6
            self.layer.shadowOffset = .init(width: 3, height: 3)
            self.clipsToBounds = false
        }
    }
    
}



