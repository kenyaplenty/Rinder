//
//  AppDelegate.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

//global value of the signed in User
var signedInUser: User?

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    //for adding example users
    struct ExampleUser {
        var id, name, email: String
    }

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Rinder")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Google Sign-In
    func application(_ application: UIApplication,
                     open googleUrl: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(googleUrl)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open googleUrl: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(googleUrl)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
                
            }
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        //Signin user or register them
        let viewContext = self.persistentContainer.viewContext
        UserHelper.userSignedIn(viewContext: viewContext,
                                googleUser: user)
        
        let notification = NotificationCenter.default
        notification.post(name: Notification.Name("UserLoggedIn"), object: nil)
        
        addExampleUsers()
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
    // MARK: - Example users
    func addExampleUsers() {
        let testUserId = "testUserId1"
        
        persistentContainer.performBackgroundTask { (context) in
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", testUserId)
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
                    ExampleUser(id: "testUserId6", name: "Ester Chest", email: "ester@gmail.com")]
                
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

