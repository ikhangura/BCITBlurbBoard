//
//  SingleArticleCellControllerTableViewCell.swift
//  BCITBlurbBoard
//
//  Created by alan on 3/11/15.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit

class SingleArticleCellControllerTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


