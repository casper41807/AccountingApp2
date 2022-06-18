//
//  DetailTableViewCell.swift
//  AccountingApp2
//
//  Created by 陳秉軒 on 2022/6/8.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
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
