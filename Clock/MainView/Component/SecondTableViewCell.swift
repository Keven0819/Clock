//
//  SecondTableViewCell.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/12.
//

import UIKit

class SecondTableViewCell: UITableViewCell {

    @IBOutlet weak var lbList: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var swAlarm: UISwitch!
    
    static let identifier = "SecondTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
