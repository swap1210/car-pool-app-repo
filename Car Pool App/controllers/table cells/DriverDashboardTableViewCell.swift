//
//  DriverDashboardTableViewCell.swift
//  Car Pool App
//
//  Created by Ly, Bao Thai on 10/24/22.
//

import UIKit

class DriverDashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var requester: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
