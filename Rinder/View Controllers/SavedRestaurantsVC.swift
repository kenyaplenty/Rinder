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
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: "SavedRestaurantCell", bundle: nil), forCellReuseIdentifier: "SavedRestaurantCell")
    }
    
    private func getSavedData() {
        guard let context = context else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let request: NSFetchRequest<SavedRestaurant> = SavedRestaurant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            savedRestaurants = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error getting saved restaurants: \(error.localizedDescription)")
        }
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
}
