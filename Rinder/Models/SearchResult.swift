//
//  SearchResult.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import Foundation

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
        if !restaurants.isEmpty,
           currentIndex < restaurants.count - 1 {
            self.currentIndex += 1
            return restaurants[currentIndex]
        } else {
            return nil
        }
    }
    func getCurrentRestaurant() -> Restaurant? {
        if !restaurants.isEmpty,
           currentIndex < restaurants.count - 1 {
            return restaurants[currentIndex]
        } else {
             return nil
        }
    }
}
