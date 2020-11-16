//
//  ViewController.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var signInBtn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    @IBAction func signInBtnTap(_ sender: Any) {
        let viewController = HomeVC()
        
        viewController.modalPresentationStyle = .currentContext
        viewController.modalTransitionStyle = .coverVertical
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
}

