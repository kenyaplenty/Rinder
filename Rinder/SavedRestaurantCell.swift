//
//  SavedRestaurantCell.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import UIKit

class SavedRestaurantCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func populate(savedResaurant: SavedRestaurant) {
        titleLbl.text = savedResaurant.name ?? ""
    }
}
