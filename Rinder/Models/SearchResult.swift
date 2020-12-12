//
//  SearchResult.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import Foundation
import UIKit
import CoreData

class SearchResult: NSObject {
    var successfulFetch: Bool = false
    var restaurants: [Restaurant] = []
    var currentIndex: Int = 0
    
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    
    var totalResultsCount: Int = 0 //how many possible restaurants to fetch
    private var isFetchingMoreRestaurants: Bool = false
    
    init (from restaurantsJSONArray: [AnyObject]?,
          latitude: Double = 0.0,
          longitude: Double = 0.0,
          totalResults: Int = 0) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.totalResultsCount = totalResults
        
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
    
    func checkForMoreRestaurants() {
        if !isFetchingMoreRestaurants,
           restaurants.count - currentIndex <= 6 {
            isFetchingMoreRestaurants = true
            
            RestaurantHelper.getRestaurants(latitude: self.latitude,
                                            longitude: self.longitude,
                                            start: restaurants.count) { (searchResult) in
                self.isFetchingMoreRestaurants = false
                self.restaurants += searchResult.restaurants
            }
        }
    }
    
    //MARK: Make fake users that favorited some of the search results
    func addFavoritesToExampleUsers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, !restaurants.isEmpty else { return }
        
        appDelegate.persistentContainer.performBackgroundTask { (context) in
            //get example users
            
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "isExampleUser = true")
            
            do {
                let exampleUsers = try context.fetch(request)
                
                if exampleUsers.isEmpty { return }
                
                for exampleUser in exampleUsers {
                    if let favs = exampleUser.favRestaurants {
                        exampleUser.removeFromFavRestaurants(favs)
                    }
                    
                    //have example user favorite 3 random restaurants
                    for _ in 0..<5 {
                        
                        var restaurant : Restaurant?
                        if self.restaurants.count >= 10 {
                            let index = Int.random(in: 0..<10)
                            restaurant = self.restaurants[index]
                        } else {
                            restaurant = self.restaurants.randomElement()
                        }
                        
                        if let restaurant = restaurant,
                           !restaurant.isItemSaved(isCheckingFavorites: true, user: exampleUser) {
                            let savedRestaurant = restaurant.convertToSavedRestaurantModel(context: context)
                            exampleUser.addToFavRestaurants(savedRestaurant)
                        }
                    }
                }
                
                try context.save()
            } catch {
                print("Hey Listen! Error adding favs to example users: \(error.localizedDescription)")
            }
            
        }
        
    }
}
