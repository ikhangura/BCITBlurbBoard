//
//  NewsItemCell.swift
//  BCITBlurbBoard
//
//  Created by Matthew Banman on 2015-03-12.
//  Copyright (c) 2015 Ben Soer. All rights reserved.
//

import UIKit

class FilteredNewsItemCell: UITableViewCell {
    
    @IBOutlet weak var MessagePreview: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var CommentNum: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var CellTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
