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
    @IBOutlet weak var backBtn: UIButton!
    
    //MARK: - Variables
    
    var context: NSManagedObjectContext?
    var usersFound = [User]()
    
    var testContext: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
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
        tableView.register(UINib(nibName: "UserSearchResultCell", bundle: nil), forCellReuseIdentifier: "UserSearchResultCell")
        
        searchBar.placeholder = "Email"
        searchBar.delegate = self
    }
    
    @IBAction func backBtnTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate

extension SearchUserVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let context = self.context,
              let currentUserId = signedInUser?.userId,
              let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else { return }
        findUser(searchText: searchText, currentUserId: currentUserId, context: context)
    }
    
    func findUser(searchText: String, currentUserId: String, context: NSManagedObjectContext) {
        guard let context = self.context else { return }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchResultCell") as? UserSearchResultCell else {
            return UITableViewCell()
        }
        
        cell.populate(user: usersFound[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= usersFound.count { return }
        
        let viewController = ProfileVC()
        viewController.context = context
        viewController.user = usersFound[indexPath.row]
        self.present(viewController, animated: true, completion: nil)
    }
}
