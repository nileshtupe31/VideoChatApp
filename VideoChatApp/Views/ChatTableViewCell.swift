//
//  ChatTableViewCell.swift
//  VideoChatApp
//
//  Created by Nilesh on 09/09/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureViewWithMessage(message:[String: Any]) {
        if let user = message["user"] as? [String: Any] {
            if let userName = user["nickname"] as? String {
                userLabel.text = userName
            }
        }
        
        if let message = message["message"] as? String {
            messageLabel.text = message
        }
    }
    
}
