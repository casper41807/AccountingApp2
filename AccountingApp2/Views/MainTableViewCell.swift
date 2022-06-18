//
//  MainTableViewCell.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/5/27.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
