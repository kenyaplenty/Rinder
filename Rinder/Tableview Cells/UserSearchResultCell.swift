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
        self.selectionStyle = .none
    }

    func populate(user: User) {
        titleLbl.text = user.name
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        detailsLbl.text = user.email
        detailsLbl.font = UIFont.systemFont(ofSize: 15, weight: .light)
        detailsLbl.textColor = UIColor.darkGray
        
    }
}
