//
//  Restaurant.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import Foundation
import CoreLocation


class Restaurant: NSObject {
    var id: String = ""
    var name: String = ""
    var featuredImageURL: URL?
    var url: String = ""
    var address: String = ""
    var location: CLLocation?
    var cuisines: String = ""
    var price_range: String = ""
    
    init(from jsonDict: NSDictionary) {
        if let id = jsonDict["id"] as? String {
            self.id = id
        }
        
        if let name = jsonDict["name"] as? String {
            self.name = name
        }
        
        if let featuredImageString = jsonDict["featured_image"] as? String,
           let featuredImageURL = URL(string: featuredImageString){
            self.featuredImageURL = featuredImageURL
        }
        
        if let url = jsonDict["url"] as? String {
            self.url = url
        }
        
        if let location = jsonDict["location"] as? NSDictionary {
            if let address = location["address"] as? String {
                self.address = address
            }
            
            if let latString = location["latitude"] as? String,
               let lat = Float(latString),
               let lonString = location["longitude"] as? String,
               let lon = Float(lonString) {
                self.location = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
            }
        }
        
        if let cuisines = jsonDict["cuisines"] as? String {
            self.cuisines = cuisines
        }
        
        if let price_range = jsonDict["price_range"] as? String {
            self.price_range = price_range
        }
    }
}


class SearchResult: NSObject {
    var successfulFetch: Bool = false
    var restaurants: [Restaurant] = []
    var currentIndex: Int = 0
    
    init (from restaurantsJSONArray: [AnyObject]?) {
        guard let restaurantsJSONArray = restaurantsJSONArray else { return }
        
        successfulFetch = true
        
        for restaurantJSON in restaurantsJSONArray {
            if let restaurantDict = restaurantJSON as? NSDictionary,
               let restaurantDetailsDict = restaurantDict["restaurant"] as? NSDictionary {
                restaurants.append(Restaurant(from: restaurantDetailsDict))
            }
        }
    }
    
    //return the next restaurant in the list if we have one
    func nextRestaurant() -> Restaurant? {
        if currentIndex < restaurants.count - 1 {
            self.currentIndex += 1
            return restaurants[currentIndex]
        } else {
            return nil
        }
    }
}
