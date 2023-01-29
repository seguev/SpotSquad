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
        spotImageView.image = UIImage(systemName: "\(i).circle.fill")
        setGradientColor(i, to: spotImageView)
//        setShadow(spotImageView)
    }
    
    private func setGradientColor (_ i:Int, to image:UIImageView) {
        switch i {
        case 1:
            let colors : [CGColor] = [UIColor.purple.cgColor,UIColor.systemPurple.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = layer.frame
            ;#warning("continue from here")

            image.tintColor = .purple
            
        case 2:
            let colors : [CGColor] = [UIColor.blue.cgColor,UIColor.systemBlue.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = layer.frame
            ;#warning("continue from here")

            image.tintColor = .blue
        case 3:
            let colors : [CGColor] = [UIColor.brown.cgColor,UIColor.systemBrown.cgColor]
            let gradient = CAGradientLayer()
            gradient.colors = colors
            gradient.frame = layer.frame
            ;#warning("continue from here")

            image.tintColor = .brown
        default:
            break
        }
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
        
        UIView.animate(withDuration: 0.2) {
            self.layer.shadowOffset = .init(width: 1, height: 1)
            self.layer.shadowRadius = 5
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowOpacity = 0.4
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.layer.shadowOffset = .init(width: 3, height: 3)
                self.layer.shadowRadius = 10
                self.layer.shadowColor = UIColor.darkGray.cgColor
                self.layer.shadowOpacity = 0.8
            }
            
        }
    }
}
