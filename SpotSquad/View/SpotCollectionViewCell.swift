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
//        setGradientColor(i, to: spotImageView)
        spotImageView.image = UIImage(systemName: "\(i).circle")
        spotImageView.tintColor = #colorLiteral(red: 0.5176470588, green: 0.8235294118, blue: 0.7725490196, alpha: 1)
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
    
    /*private func setGradientColor (_ i:Int, to view:UIView) {
        switch i {
        case 1:
            
            let colors : [CGColor] = [UIColor.purple.cgColor,UIColor.systemPurple.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = view.bounds
            gradient.masksToBounds = true
            gradient.cornerRadius = (view.frame.width+view.frame.height)/2
            gradient.shadowOpacity = 0.5
            gradient.
            view.layer.insertSublayer(gradient, at: 0)
            
        case 2:
            let colors : [CGColor] = [UIColor.blue.cgColor,UIColor.systemBlue.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = layer.frame
            ;#warning("continue from here")

//            image.tintColor = .blue
        case 3:
            let colors : [CGColor] = [UIColor.brown.cgColor,UIColor.systemBrown.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = layer.frame
            ;#warning("continue from here")

//            image.tintColor = .brown
        default:
            break
        }
    }*/
    
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
