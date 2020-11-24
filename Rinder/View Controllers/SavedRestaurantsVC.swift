//
//  SavedRestaurantsVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/13/20.
//

import UIKit
import CoreData

class SavedRestaurantsVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var context: NSManagedObjectContext?
    private var savedRestaurants = [SavedRestaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        getSavedData()
    }
    
    private func setupView() {
        titleLbl.text = "Saved Restaurants"
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = UIColor.white
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: "SavedRestaurantCell", bundle: nil), forCellReuseIdentifier: "SavedRestaurantCell")
    }
    
    private func getSavedData() {
        guard let user = signedInUser else { return }
        
        var restaurants = [SavedRestaurant]()
        if let restaurantsSet = user.savedRestaurants {
            for savedRestaurant in restaurantsSet {
                if let restaurant = savedRestaurant as? SavedRestaurant {
                    restaurants.append(restaurant)
                }
            }
        }
        
        self.savedRestaurants = restaurants
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension SavedRestaurantsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedRestaurantCell") as? SavedRestaurantCell else {
            return UITableViewCell()
        }
        
        cell.populate(savedResaurant: savedRestaurants[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            if let context = self.context {
                let restaurantToDelete = self.savedRestaurants[indexPath.row]
                self.savedRestaurants.remove(at: indexPath.row)
                do {

                    if let user = signedInUser {
                        user.removeFromSavedRestaurants(restaurantToDelete)
                    }
                    
                    context.delete(restaurantToDelete)
                    
                    try context.save()
                    tableView.reloadData()
                } catch {
                    print("Error deleting saved restaurant: \(error.localizedDescription)")
                }
            }
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
