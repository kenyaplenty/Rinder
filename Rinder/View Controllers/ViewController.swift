//
//  ViewController.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import CoreData
import GoogleSignIn

class ViewController: UIViewController {
    
    struct ExampleUser {
        var id, name, email: String
    }

    //MARK: - Outlets
    
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var signInBtn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToHome), name: Notification.Name("UserLoggedIn"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        autoSignIn()
    }
    
    private func autoSignIn() {
        if (GIDSignIn.sharedInstance().hasPreviousSignIn()) {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            goToHome()
        }
    }
    
    @objc private func goToHome() {
        let viewController = HomeVC()
        viewController.modalPresentationStyle = .currentContext
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
    }
    
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
    
    @IBAction func testBtnPressed(_ sender: Any) {
        let testUserId = "testUserId1"
        
        persistentContainer.performBackgroundTask { (context) in
            let request : NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", testUserId)
            do {
                let countRequests = try context.count(for: request)
                //Check example users need to be added
                if countRequests > 0 { return }
                
                let example = ExampleUser(id: "testUserId1", name: "ASE TEAM", email: "ase@gmail.com")
                let user = User(context: context)
                user.userId = example.id
                user.name = example.name
                user.email = example.email
                user.isExampleUser = true
                
                try context.save()
            } catch {
                print("Hey Listen! Error checking if a test user exits: \(error.localizedDescription)")
            }
            
        }
        
        goToHome()
    }
}

