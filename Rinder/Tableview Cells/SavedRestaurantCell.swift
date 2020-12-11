//
//  SavedRestaurantCell.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import UIKit
import CoreData

class SavedRestaurantCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cuisineLbl: UILabel!
    @IBOutlet weak var favStarIv: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        favStarIv.image = UIImage(systemName: "star.fill")
        favStarIv.isHidden = true
        favStarIv.tintColor = .white
    }

    func populate(savedResaurant: SavedRestaurant, shouldHideStars: Bool = false) {
        titleLbl.text = savedResaurant.name ?? ""
        titleLbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLbl.textColor = UIColor.white
    
        cuisineLbl.text = savedResaurant.cuisines
        cuisineLbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cuisineLbl.textColor = UIColor.darkGray
        
        favStarIv.isHidden = UserHelper.getSavedRestaurantInstance(restaurantId: savedResaurant.id) == nil || shouldHideStars
        favStarIv.image = UIImage(systemName: "star.fill")
    }
    
    //toggle favorite and remove
    func toggleFavorite(context: NSManagedObjectContext?, savedRestaurant: SavedRestaurant) {
        guard let context = context, let user = signedInUser else { return }
        
        var becameFavorite = false
        
        if let favedRestaurant = UserHelper.getSavedRestaurantInstance(restaurantId: savedRestaurant.id) {
            user.removeFromFavRestaurants(favedRestaurant)
        } else {
            let favRestaurant = SavedRestaurantHelper.getDuplicateSavedRestaurant(context: context, savedRestaurant: savedRestaurant)
            user.addToFavRestaurants(favRestaurant)
            becameFavorite = true
        }
        
        do {
            try context.save()
        } catch {
            print("Error favoriting saved restaurant: \(error.localizedDescription)")
        }
        
        favStarIv.isHidden = !becameFavorite
    }
}
