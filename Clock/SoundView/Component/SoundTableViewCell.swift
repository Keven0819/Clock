//
//  SoundTableViewCell.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/8.
//

import UIKit

class SoundTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbTest: UILabel!
    
    static let identifier = "SoundTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
