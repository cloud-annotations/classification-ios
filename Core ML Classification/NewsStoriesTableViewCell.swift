//
//  NewsStoriesTableViewCell.swift
//  Core ML Vision
//
//  Created by Quinnan Gill on 9/7/19.
//

import UIKit

class NewsStoriesTableViewCell: UITableViewCell {

    // Mark Properties
    @IBOutlet weak var headLine: UILabel!
    @IBOutlet weak var socialRate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
