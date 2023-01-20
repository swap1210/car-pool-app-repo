//
//  PassengerDashboardTableViewCell.swift
//  Car Pool App
//
//  Created by Ly, Bao Thai on 10/24/22.
//

import UIKit

class PassengerDashboardTableViewCell: UITableViewCell {

    
    @IBOutlet weak var driver: UILabel!
    @IBOutlet weak var passengers: UILabel!
    @IBOutlet weak var destination: UILabel!
    var itHasMe: Bool!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
