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
    
    //MARK: Make fake users that favorited some of the search results
    func addFavoritesToExampleUsers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, restaurants.count > 0 else { return }
        
        appDelegate.persistentContainer.performBackgroundTask { (context) in
            //get example users
            
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "isExampleUser = true")
            
            do {
                let exampleUsers = try context.fetch(request)
                
                if exampleUsers.count == 0 { return }
                
                for exampleUser in exampleUsers {
                    if let favs = exampleUser.favRestaurants {
                        exampleUser.removeFromFavRestaurants(favs)
                    }
                    
                    //have example user favorite 3 random restaurants
                    for _ in 0..<5 {
                        if let restaurant = self.restaurants.randomElement(),
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
