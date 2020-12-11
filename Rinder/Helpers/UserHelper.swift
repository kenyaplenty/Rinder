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
    
    struct ExampleUser {
        var id, name, email: String
    }
    
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
    
    static func addExampleUsers(container: NSPersistentContainer) {
        let idToCheck = "testUserId1"
        container.performBackgroundTask { (context) in
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", idToCheck)
            do {
                let countRequests = try context.count(for: request)
                //Check example users need to be added
                if countRequests > 0 { return }
                
                let exampleArray: [ExampleUser] = [
                    ExampleUser(id: "testUserId1", name: "Tom John", email: "tom@gmail.com"),
                    ExampleUser(id: "testUserId2", name: "Addison Ra", email: "add@gmail.com"),
                    ExampleUser(id: "testUserId3", name: "Bond Jame", email: "bond@gmail.com"),
                    ExampleUser(id: "testUserId4", name: "Cam Com", email: "cam@gmail.com"),
                    ExampleUser(id: "testUserId5", name: "Daniel Damn", email: "damn@gmail.com"),
                    ExampleUser(id: "testUserId6", name: "Ester Chest", email: "ester@gmail.com"),
                    ExampleUser(id: "testUserId7", name: "adam aaron", email: "adam@gmail.com"),
                    ExampleUser(id: "testUserId8", name: "aaron johnson", email: "aaron@gmail.com")]
                
                for example in exampleArray {
                    let user = User(context: context)
                    user.userId = example.id
                    user.name = example.name
                    user.email = example.email
                    user.isExampleUser = true
                }
                
                try context.save()
            } catch {
                print("Hey Listen! Error checking if a test user exits: \(error.localizedDescription)")
            }
            
        }
    }
}
