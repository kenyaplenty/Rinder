//
//  UserModelExtension.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/24/20.
//

import Foundation
import CoreData

class UserHelper {
    
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
}
