//
//  UserSearchResultCell.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/24/20.
//

import UIKit

class UserSearchResultCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    
    //MARK: - Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }

    func populate(user: User) {
        titleLbl.text = user.name
        detailsLbl.text = user.email
    }
}
