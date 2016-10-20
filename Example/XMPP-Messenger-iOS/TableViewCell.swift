//
//  TableViewCell.swift
//  XMPP-Messenger-iOS
//
//  Created by Higher Visibility on 10/15/16.
//  Copyright © 2016 ProcessOne. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var unreadMessages: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
