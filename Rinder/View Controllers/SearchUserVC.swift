//
//  SearchUserVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/24/20.
//

import UIKit
import CoreData

class SearchUserVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    
    var context: NSManagedObjectContext?
    var usersFound = [User]()
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        titleLbl.text = "Find Friends"
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = UIColor.white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        searchBar.placeholder = "Email"
        searchBar.delegate = self
    }
}

//MARK: - UISearchBarDelegate

extension SearchUserVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let context = self.context,
              let currentUserId = signedInUser?.userId,
              let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return }
        
        let request : NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ && userId != %@",
                                        argumentArray: [searchText, currentUserId])
        request.sortDescriptors = [NSSortDescriptor(key: "email", ascending: true)]
        
        do {
            usersFound = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("Hey Listen! Error finding users: \(error.localizedDescription)")
        }
    }
}

//MARK: - Tableview

extension SearchUserVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersFound.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let user = usersFound[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
}
