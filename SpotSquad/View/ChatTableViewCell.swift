//
//  ChatTableViewCell.swift
//  CoffeeFetch
//
//  Created by segev perets on 13/01/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {


    
    enum Sender {
        case currentUser
        case otherUser
    }
    
    var mainText : String?
    var secondaryText : String?
    var sender : Sender?
    
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var content = defaultContentConfiguration().updated(for: state)
        var background = defaultBackgroundConfiguration().updated(for: state)
        
        content.text = mainText
        content.textProperties.numberOfLines = 0
        content.textProperties.alignment = .natural
        content.textProperties.font = .systemFont(ofSize: 17)
        content.secondaryText = secondaryText
        content.secondaryTextProperties.font = .italicSystemFont(ofSize: 13)

        content.prefersSideBySideTextAndSecondaryText = false
        content.textToSecondaryTextVerticalPadding = 5
        background.cornerRadius = 15
        
        if let mainText, mainText.isRightToLeft {
            semanticContentAttribute = .forceRightToLeft
        }
        

        
        if sender == .currentUser {
            background.backgroundInsets = .init(top: 10, leading: 25, bottom: 10, trailing: 80)
            content.directionalLayoutMargins = .init(top: 15, leading: 35, bottom: 15, trailing: 90)
            background.backgroundColor = .systemBlue
        } else if sender == .otherUser {
            background.backgroundInsets = .init(top: 10, leading: 80, bottom: 10, trailing: 25)
            content.directionalLayoutMargins = .init(top: 15, leading: 90, bottom: 15, trailing: 35)
            background.backgroundColor = .blue
        }
        
        contentConfiguration = content
        backgroundConfiguration = background
    }
    
}

