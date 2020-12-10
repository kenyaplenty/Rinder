//
//  UserModelExtension.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/24/20.
//

import Foundation
import GoogleSignIn
import CoreData

class UserHelper {
    
    //Make a user model in the database if it's the first time the user signed in
    static func userSignedIn(viewContext: NSManagedObjectContext,
                             userId: String,
                             name: String,
                             email: String) {
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId = %@", userId)
        do {
            if let user = try viewContext.fetch(request).first {
                signedInUser = user
            }
            //register user
            else {
                let user = User(context: viewContext)
                
                user.userId = userId
                user.name = name
                user.email = email
                
                do {
                    try viewContext.save()
                    signedInUser = user
                } catch {
                    print("Error saving user: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Hey Listen! Error getting user: \(error.localizedDescription)")
        }
    }
    
    //Checks user's favorite restaurants and returns the instance of it
    static func getSavedRestaurantInstance(restaurantId: String?) -> SavedRestaurant? {
        guard let user = signedInUser, let restaurantId = restaurantId else { return nil }
        
        if let favs = user.favRestaurants {
            for favoriteRest in favs {
                if let restaurant = favoriteRest as? SavedRestaurant,
                   restaurant.id == restaurantId {
                    return restaurant
                }
            }
        }
        
        return nil
    }
}
