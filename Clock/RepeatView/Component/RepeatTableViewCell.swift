//
//  RepeatTableViewCell.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/6.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbTest: UILabel!
    
    static let identifier = "RepeatTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
