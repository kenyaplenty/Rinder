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
    @IBOutlet weak var initialLbl: UILabel!
    @IBOutlet weak var initialBackground: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var favLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    //MARK: - Variables
    var context: NSManagedObjectContext?
    var user: User?
    var favRestuarants = [SavedRestaurant]()
    
    private var isCurrentUser = false
    
    //MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        if isCurrentUser {
            getFavs()
        } else {
            getFaceOffResult()
        }
    }

    func setupView() {
        titleLbl.text = "Profile"
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = UIColor.white
        
        nameLbl.textColor = .white
        emailLbl.textColor = .white
        
        favLbl.textColor = .white
        favLbl.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        initialBackground.layer.cornerRadius = initialBackground.frame.size.width/2
        initialBackground.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "SavedRestaurantCell", bundle: nil), forCellReuseIdentifier: "SavedRestaurantCell")
        
        logoutBtn.isHidden = true
        
        guard let user = user else { return }
        let name = user.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        nameLbl.text = name
        emailLbl.text = user.email ?? ""

        let nameArray = name.components(separatedBy: " ")
        if nameArray.count > 1, let firstLetter = nameArray.first?.first, let lastLetter = nameArray.last?.first {
            initialLbl.text = "\(firstLetter)\(lastLetter)"
        } else if nameArray.count == 1, let firstLetter = nameArray.first?.first {
            initialLbl.text = "\(firstLetter)"
        }
        
        //show logout if user is looking at their own profile
        if let currentUser = signedInUser, currentUser == user {
            isCurrentUser = true
            logoutBtn.isHidden = false
        }
    }
    
    func getFavs() {
        favLbl.text = "Favorites"
        
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
    
    func getFaceOffResult() {
        favLbl.text = "Face-off Results"
        
        guard let user = user,
              let myFavs = signedInUser?.favRestaurants?.allObjects as? [SavedRestaurant],
              let friendFavs = user.favRestaurants?.allObjects as? [SavedRestaurant] else { return }
        
        var similarFavs = [SavedRestaurant]()
        for myFav in myFavs {
            for friendFav in friendFavs {
                if myFav.id == friendFav.id {
                    similarFavs.append(friendFav)
                }
            }
        }
        
        favRestuarants = similarFavs
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
    
    @IBAction func backBtnTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !isCurrentUser { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            if let context = self.context {
                
                let restaurantToDelete = self.favRestuarants[indexPath.row]
                self.favRestuarants.remove(at: indexPath.row)
                do {

                    if let user = signedInUser {
                        user.removeFromFavRestaurants(restaurantToDelete)
                    }
                    
                    context.delete(restaurantToDelete)
                    
                    try context.save()
                    tableView.reloadData()
                } catch {
                    print("Error deleting saved restaurant: \(error.localizedDescription)")
                }
                
                NotificationCenter.default.post(name: Notification.Name("favoriteStatusChanged"), object: nil)
            }
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
