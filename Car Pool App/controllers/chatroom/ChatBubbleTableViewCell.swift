//
//  ChatBubbleTableViewCell.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/19/22.
//

import UIKit

class ChatBubbleTableViewCell: UITableViewCell {
    @IBOutlet weak var atLabel: UILabel!
    @IBOutlet weak var bubbleImg: UIImageView!
    @IBOutlet weak var message: UILabel!
    
    //constraints
    @IBOutlet weak var bubbleImgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setBubbleAndRide(selfBubble: Bool,isDriver: Bool,bubble: ChatBubble){
        guard let sentImage = UIImage(named: "chat_bubble_sent") else { return }
        guard let receivedImage = UIImage(named: "chat_bubble_received") else { return }
        var messagePrefix = ""
        
        self.bubbleImg.image = sentImage.resizableImage(withCapInsets:UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode:.stretch).withRenderingMode(.alwaysTemplate)
        self.bubbleImg.tintColor = UIColor(named: "chat_bubble_color_sent")
        self.message.textColor = UIColor(named: "chat_text_color_sent")
        self.atLabel.textColor = UIColor(named: "chat_text_color_sent")
        
        if selfBubble{//self bubble
            messagePrefix = "Me"
        }else{//others bubble
            messagePrefix = bubble.from
            self.bubbleImg.image = receivedImage.resizableImage(withCapInsets:UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),resizingMode:.stretch).withRenderingMode(.alwaysTemplate)
            self.bubbleImg.tintColor = UIColor(named: "chat_bubble_color_received")
            self.message.textColor = UIColor(named: "chat_text_color_received")
            self.atLabel.textColor = UIColor(named: "chat_text_color_received")
        }
        
        if(isDriver){
            messagePrefix = messagePrefix + " (driver)"
        }
        self.message.text = messagePrefix+": "+bubble.message
        self.atLabel.text = bubble.at.dateValue().formatted()
    }
}
