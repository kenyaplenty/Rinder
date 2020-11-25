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
                             googleUser: GIDGoogleUser) {
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId = %@", googleUser.userID)
        do {
            if let user = try viewContext.fetch(request).first {
                signedInUser = user
            }
            //register user
            else {
                let user = User(context: viewContext)
                
                user.userId = googleUser.userID
                user.name = googleUser.profile.name
                user.email = googleUser.profile.email
                
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
            for fav in favs {
                if let restaurant = fav as? SavedRestaurant,
                   restaurant.id == restaurantId {
                    return restaurant
                }
            }
        }
        
        return nil
    }
}
