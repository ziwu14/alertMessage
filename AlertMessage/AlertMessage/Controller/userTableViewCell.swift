//
//  userTableViewCell.swift
//  AlertMessage
//
//  Created by shadowsdietwice on 11/19/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit

class userTableViewCell: UITableViewCell {

    @IBOutlet weak var friendPhoto: RoundImage!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
