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
    //save restaurant
    func saveToCoreData(context: NSManagedObjectContext?) {
        guard let context = context, !isItemSaved(context: context) else { return }
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
        
        do {
            if let user = signedInUser {
                user.addToSavedRestaurants(savedRestaurant)
            }
            
            try context.save()
        } catch {
            print("Error saving restaurant: \(error.localizedDescription)")
        }
    }
    func isItemSaved(context: NSManagedObjectContext) -> Bool {
        if self.id == "" { return false }
        let request: NSFetchRequest<SavedRestaurant> = SavedRestaurant.fetchRequest()
        request.predicate = NSPredicate(format: "id == \(self.id)")
        do {
            return try context.count(for: request) > 0
        } catch {
            print("Error checking how many times we've saved this restaurant: \(error.localizedDescription)")
            return false
        }
    }
}
