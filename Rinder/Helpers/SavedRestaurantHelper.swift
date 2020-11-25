//
//  SavedRestaurantHelper.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/25/20.
//

import Foundation
import CoreData

class SavedRestaurantHelper {
    
    static func getDuplicateSavedRestaurant(context: NSManagedObjectContext, savedRestaurant: SavedRestaurant) -> SavedRestaurant {
        let restaurant = SavedRestaurant(context: context)
        restaurant.cuisines = savedRestaurant.cuisines
        restaurant.featuredImageURLString = savedRestaurant.featuredImageURLString
        restaurant.id = savedRestaurant.id
        restaurant.name = savedRestaurant.name
        restaurant.priceRange = savedRestaurant.priceRange
        restaurant.latitude = savedRestaurant.latitude
        restaurant.longitude = savedRestaurant.longitude
        
        return restaurant
        
    }
    
}
