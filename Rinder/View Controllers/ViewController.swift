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

    //MARK: - Outlets
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var signInBtn: GIDSignInButton!
    
    //MARK: - Variables
    var context: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
    //MARK: - Setup
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
    
    @IBAction func testBtnPressed(_ sender: Any) {
        guard let context = context else { return }
        UserHelper.userSignedIn(viewContext: context,
                                userId: "fakeUserId",
                                name: "Fake User",
                                email: "fake@gmail.com")
        
        NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)
    }
}

