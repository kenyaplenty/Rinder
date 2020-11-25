//
//  SavedRestaurantCell.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import UIKit

class SavedRestaurantCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cuisineLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func populate(savedResaurant: SavedRestaurant) {
        titleLbl.text = savedResaurant.name ?? ""
        titleLbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLbl.textColor = UIColor.white
    
        cuisineLbl.text = savedResaurant.cuisines
        cuisineLbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cuisineLbl.textColor = UIColor.darkGray
    }
}
