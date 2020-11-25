//
//  Restaurant.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import Foundation
import CoreLocation
import CoreData

class Restaurant: NSObject {
    var id: String = ""
    var name: String = ""
    var featuredImageURL: URL?
    var menuURL: URL?
    var address: String = ""
    var location: CLLocation?
    var cuisines: String = ""
    var priceRange: String = ""
    init(from jsonDict: NSDictionary) {
        if let id = jsonDict["id"] as? String {
            self.id = id
        }
        if let name = jsonDict["name"] as? String {
            self.name = name
        }
        
        if let featuredImageString = jsonDict["featured_image"] as? String,
           let featuredImageURL = URL(string: featuredImageString) {
            self.featuredImageURL = featuredImageURL
        }
        if let menuURLString = jsonDict["menu_url"] as? String,
           let menuURL = URL(string: menuURLString) {
            self.menuURL = menuURL
        }
        if let location = jsonDict["location"] as? NSDictionary {
            if let address = location["address"] as? String {
                self.address = address
            }
            if let latString = location["latitude"] as? String,
               let latitudeFloat = Float(latString),
               let lonString = location["longitude"] as? String,
               let longitudeFloat = Float(lonString) {
                self.location = CLLocation(latitude: CLLocationDegrees(latitudeFloat), longitude: CLLocationDegrees(longitudeFloat))
            }
        }
        if let cuisines = jsonDict["cuisines"] as? String {
            self.cuisines = cuisines
        }
        if let price_range = jsonDict["price_range"] as? String {
            self.priceRange = price_range
        }
    }
    
    //put restaurant in saved or favorites
    func saveToCoreData(context: NSManagedObjectContext?, saveToFavorites: Bool) {
        guard let context = context, !isItemSaved(isCheckingFavorites: saveToFavorites, user: signedInUser) else { return }
        
        let savedRestaurant = convertToSavedRestaurantModel(context: context)
        
        do {
            if let user = signedInUser {
                if saveToFavorites {
                    user.addToFavRestaurants(savedRestaurant)
                } else {
                    user.addToSavedRestaurants(savedRestaurant)
                }
            }
            
            try context.save()
        } catch {
            print("Error saving restaurant: \(error.localizedDescription)")
        }
    }
    
    //check if restuarant is saved or favorited
    func isItemSaved(isCheckingFavorites: Bool, user: User?) -> Bool {
        //don't save if we don't have a user
        guard let user = (user == nil ? signedInUser : user) else { return true }
        
        if let restaurantsSet = isCheckingFavorites ? user.favRestaurants : user.savedRestaurants {
            for savedRestaurant in restaurantsSet {
                if let restaurant = savedRestaurant as? SavedRestaurant,
                   let currentId = restaurant.id,
                   currentId == self.id {
                    return true
                }
            }
        }
        return false
    }
    
    //remove restaurant from favorites
    func removeFromFavorites(context: NSManagedObjectContext?) {
        guard let context = context,
              let user = signedInUser,
              let favRestaurants = user.favRestaurants else { return }
        
        for fav in favRestaurants {
            if let favRestaurant = fav as? SavedRestaurant,
               let favId = favRestaurant.id,
               self.id == favId {
                
                do {
                    context.delete(favRestaurant)
                    try context.save()
                } catch {
                    print("Error deleting fav restaurant: \(error.localizedDescription)")
                }
                
                return
            }
        }
    }
    
    //converts the restaurant into a core data model to save it on the phone
    func convertToSavedRestaurantModel(context: NSManagedObjectContext) -> SavedRestaurant {
        let savedRestaurant = SavedRestaurant(context: context)
        savedRestaurant.cuisines = self.cuisines
        savedRestaurant.featuredImageURLString = self.featuredImageURL?.absoluteString
        savedRestaurant.id = self.id
        savedRestaurant.name = self.name
        savedRestaurant.priceRange = self.priceRange
        if let location = self.location {
            savedRestaurant.latitude = Double(location.coordinate.latitude)
            savedRestaurant.longitude = Double(location.coordinate.longitude)
        }
        
        return savedRestaurant
    }
}
