//
//  ProfileVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/24/20.
//

import UIKit
import CoreData
import GoogleSignIn

class ProfileVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var favLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    
    //MARK: - Variables
    var context: NSManagedObjectContext?
    var user: User?
    var favRestuarants = [SavedRestaurant]()
    
    private var isCurrentUser = false
    
    //MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getFavs()
    }

    func setupView() {
        titleLbl.text = "Profile"
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "SavedRestaurantCell", bundle: nil), forCellReuseIdentifier: "SavedRestaurantCell")
        
        logoutBtn.isHidden = true
        
        guard let user = user else { return }
        nameLbl.text = user.name ?? ""
        emailLbl.text = user.email ?? ""
        
        //show logout if user is looking at their own profile
        if let currentUser = signedInUser, currentUser == user {
            isCurrentUser = true
            logoutBtn.isHidden = false
        }
    }
    
    func getFavs() {
        guard let user = user else { return }
        
        var restuarants = [SavedRestaurant]()
        if let userFavRestuarants = user.favRestaurants {
            for favRestuarant in userFavRestuarants {
                if let restuarant = favRestuarant as? SavedRestaurant {
                    restuarants.append(restuarant)
                }
            }
        }
        favRestuarants = restuarants
        tableView.reloadData()
    }
    
    //MARK: - Actions
    
    @IBAction func logoutBtnTap(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        signedInUser = nil
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        
        if let window = self.view.window {
            window.rootViewController = viewController
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            UIView.transition(with: window,
                              duration: 0.2,
                              options: options,
                              animations: nil,
                              completion: nil)
        } else {
            viewController.modalPresentationStyle = .currentContext
            viewController.modalTransitionStyle = .coverVertical
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

//MARK: - Tableview
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favRestuarants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRestaurantCell") as? SavedRestaurantCell else {
            return UITableViewCell()
        }
        
        cell.populate(savedResaurant: favRestuarants[indexPath.row])
        
        return cell
    }
    
    
}
