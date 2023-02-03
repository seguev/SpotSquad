//
//  SpotCollectionViewCell.swift
//  CoffeeFetch
//
//  Created by segev perets on 06/01/2023.
//

import UIKit

class SpotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    
 
    func spotConfig (_ name:String, index:Int) {
        placeNameLabel.text = name
        setSpotSystemImage(i: index+1)
    }
    private func setSpotSystemImage(i : Int) {

        spotImageView.image = UIImage(systemName: "\(i).circle")?.withConfiguration(UIImage.SymbolConfiguration(weight: .thin))
        
//        image?.withConfiguration(<#T##configuration: UIImage.Configuration##UIImage.Configuration#>)
//        UIImage.Configuration = .
//        spotImageView.image = image
        
        
//        spotImageView.tintColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.7725490196, alpha: 1)
        spotImageView.tintColor = .black
        self.clipsToBounds = false

        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.7607843137, green: 0.462745098, blue: 0.3921568627, alpha: 1).cgColor , #colorLiteral(red: 0.8941176471, green: 0.6973415017, blue: 0.5333333333, alpha: 1).cgColor]
        gradient.masksToBounds = true
        gradient.frame = spotImageView.frame
        spotImageView.frame = spotImageView.bounds
                
        let x = spotImageView.bounds.height * 0.84
        gradient.bounds = .init(x: 0, y: 0, width: x, height: x)
        gradient.cornerRadius = gradient.bounds.height / 2
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setShadow (_ image:UIImageView) {
        image.layer.shadowOffset = .init(width: 3, height: 3)
        image.layer.shadowRadius = 10
        image.layer.shadowColor = UIColor.darkGray.cgColor
        image.layer.shadowOpacity = 0.8
    }
    
 
    
    func click () {
        let tap = UIImpactFeedbackGenerator(style: .rigid)
        tap.prepare()
        tap.impactOccurred()
        
    }
}
