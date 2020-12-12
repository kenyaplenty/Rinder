//
//  HomeVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import CoreData
import CoreLocation
import SafariServices

class HomeVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var seachBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    //restaurant details
    @IBOutlet var backView: UIView!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var cuisineLbl: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var decisionIv: UIImageView!
    @IBOutlet weak var favoritesBtn: UIButton!
    
    //buttons
    @IBOutlet weak var leftIv: UIImageView!
    @IBOutlet weak var rightIv: UIImageView!
    @IBOutlet weak var savedBtn: UIButton!
    
    //MARK: - Variables
    
    var context: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    var fetchingRestaurants = false
    var searchResult: SearchResult?
    var isRestaurantInFavorites = false
    
    // Variables for unit tests
    var savedToCoreData = false
    var nextRestaurantCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getUserLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setupView() {
        fromLbl.text = "Restaurants near"
        fromLbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        fromLbl.textColor = UIColor.white
        fromLbl.textAlignment = .center
        
        backView.layer.cornerRadius = 16
        backView.layer.masksToBounds = true
        
        restaurantImage.layer.cornerRadius = 16
        restaurantImage.layer.masksToBounds = true
        restaurantImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        locationLbl.textAlignment = .center
        locationLbl.text = "Current Location"
        locationLbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        locationLbl.textColor = UIColor.white
        
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.text = ""
        distanceLbl.text = ""
        cuisineLbl.text = ""
        
        favoritesBtn.setTitle("Add to Favorites", for: .normal)
        favoritesBtn.setTitleColor(.systemBlue, for: .normal)
        
        errorLbl.text = "No more restaurants"
        errorLbl.textAlignment = .center
        errorLbl.numberOfLines = 0
        errorLbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        errorLbl.textColor = .white
        errorLbl.isHidden = true
        
        menuBtn.layer.cornerRadius = 16
        savedBtn.layer.cornerRadius = 16

        leftIv.image = UIImage(systemName: "xmark.circle.fill")
        leftIv.tintColor = .systemRed
        leftIv.isUserInteractionEnabled = true
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(self.rejectTap))
        leftIv.addGestureRecognizer(leftTap)
        
        rightIv.image = UIImage(systemName: "heart.circle.fill")
        rightIv.tintColor = .systemBlue
        rightIv.isUserInteractionEnabled = true
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(self.acceptTap))
        rightIv.addGestureRecognizer(rightTap)
        
        backView.isHidden = true
        
        decisionIv.alpha = 0
        decisionIv.isHidden = true
    }
    
    //MARK: - Getting/Setting the restaurant
    
    @objc private func getUserLocation() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case CLAuthorizationStatus.denied, CLAuthorizationStatus.restricted:
            errorLbl.text = "Location needed. Please enable access to your location by going to your device's Settings -> \"Privacy\" -> \"Location Services\" -> \"Rinder\""
            errorLbl.isHidden = false
            backView.isHidden = true
        default:
            errorLbl.isHidden = true
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func getRestaurants(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if fetchingRestaurants { return }
        
        //show loading
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        fetchingRestaurants = true
        RestaurantHelper.getRestaurants(latitude: Double(latitude),
                                        longitude: Double(longitude)) { (searchResultFound) in
            self.searchResult = searchResultFound
            self.fetchingRestaurants = false
            
            if !searchResultFound.successfulFetch {
                self.errorLbl.text = "Error getting restaurants"
                self.errorLbl.isHidden = false
                return
            }
            
            if let restaurant = searchResultFound.restaurants.first {
                self.updateViewWithRestaurant(restaurant: restaurant)
            } else {
                self.errorLbl.text = "No restaurants found"
                self.errorLbl.isHidden = false
            }
            
            activityIndicator.stopAnimating()
            self.view.willRemoveSubview(activityIndicator)
            
            searchResultFound.addFavoritesToExampleUsers()
        }
    }
    
    //fill in restaurant info
    func updateViewWithRestaurant(restaurant: Restaurant, isUnitTesting: Bool = false) {
        if !isUnitTesting {
            self.backView.isHidden = false
            self.errorLbl.isHidden = true
        }
        
        DispatchQueue.main.async { [self] in
            
            self.titleLbl.text = restaurant.name
            
            if let location = self.currentLocation, let restaurantLocation = restaurant.location {
                let distanceInMiles = String(format: "%.02f", location.distance(from: restaurantLocation)/1609.344)
                self.distanceLbl.text = "\(distanceInMiles) mi away"
            }
            
            self.cuisineLbl.text = "Cuisine(s): \(restaurant.cuisines)"
            
            if let imageURL = restaurant.featuredImageURL {
                self.setRestaurantImage(imageUrl: imageURL)
            } else {
                self.restaurantImage.image = #imageLiteral(resourceName: "Screen Shot 2020-11-14 at 10.33.28 PM")
            }
            
            self.menuBtn.isHidden = restaurant.menuURL == nil
            
            if let user = signedInUser, let favRestaurants = user.favRestaurants {
                for favoriteRest in favRestaurants {
                    if let favRestaurant = favoriteRest as? SavedRestaurant,
                       let favId = favRestaurant.id,
                       restaurant.id == favId {
                        self.favoritesBtn.setTitle("In Favorites", for: .normal)
                        self.isRestaurantInFavorites = true
                        return
                    }
                }
            }
            
            self.isRestaurantInFavorites = false
            self.favoritesBtn.setTitle("Add to Favorites", for: .normal)
        }
    }
    
    //fetch the image from the internet and put it on
    private func setRestaurantImage(imageUrl: URL) {
        //show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.restaurantImage.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: imageUrl),
                  let image = UIImage(data: data) else {
                activityIndicator.stopAnimating()
                return
            }
            
            DispatchQueue.main.async {
                self?.restaurantImage.image = image
                activityIndicator.stopAnimating()
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func searchBtnTap(_ sender: Any) {
        toSearch()
    }
    
    func toSearch() {
        let viewController = SearchUserVC()
        viewController.context = context
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func profileBtnTap(_ sender: Any) {
        let viewController = ProfileVC()
        viewController.context = context
        viewController.user = signedInUser
        self.present(viewController, animated: true, completion: nil)
    }
    
    func moveCard(card: UIView, moveLeft: Bool) {
        UIView.animate(withDuration: 0.2) {
            card.center = CGPoint(x: moveLeft ? card.center.x + 500 : card.center.x - 500,
                                  y: card.center.y)
            self.decisionIv.alpha = 0
            self.decisionIv.isHidden = true
        }
    }
    
    @objc func rejectTap(isUnitTesting: Bool = false) {
        if isUnitTesting {
            rejectRestaurant(isUnitTesting: true)
        } else {
            rejectRestaurant()
        }
    }
    
    func rejectRestaurant(isUnitTesting: Bool = false) {
        if !isUnitTesting {
            moveCard(card: self.backView, moveLeft: true)
        }
        nextRestaurant()
    }
    
    @objc func acceptTap(isUnitTesting: Bool = false) {
        if isUnitTesting {
            acceptRestaurant(isUnitTesting: true)
        } else {
            acceptRestaurant()
        }
    }
    
    func acceptRestaurant(isUnitTesting: Bool = false) {
        if !isUnitTesting {
            moveCard(card: self.backView, moveLeft: false)
        }
        
        if let restaurant = searchResult?.getCurrentRestaurant() {
            restaurant.saveToCoreData(context: context, saveToFavorites: false)
            savedToCoreData = true
        }
        
        nextRestaurant()
    }
    
    @objc func nextRestaurant() {
        nextRestaurantCalled = true
        //do not do anything if there's no result yet
        guard let searchResult = searchResult else { return }
        
        if let nextRestaurant = searchResult.nextRestaurant() {
            updateViewWithRestaurant(restaurant: nextRestaurant)
            searchResult.checkForMoreRestaurants()
        } else {
            DispatchQueue.main.async {
                self.backView.isHidden = true
                self.errorLbl.text = "No more restaurants"
                self.errorLbl.isHidden = false
            }
        }
    }
    
    @IBAction func menuButtonTap(_ sender: Any) {
        guard let restaurant = searchResult?.getCurrentRestaurant(),
              let menuURL = restaurant.menuURL else { return }
        
        let safariVC = SFSafariViewController(url: menuURL)
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func savedBtnTap(_ sender: Any) {
        let viewController = SavedRestaurantsVC()
        viewController.context = context
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func favoritesBtnTap(_ sender: Any) {
        if self.isRestaurantInFavorites {
            if let restaurant = searchResult?.getCurrentRestaurant() {
                restaurant.removeFromFavorites(context: context)
            }
            self.favoritesBtn.setTitle("Add to favorites", for: .normal)
        } else if signedInUser?.favRestaurants?.count ?? 0 >= 5 {
            self.createAlert(title: "Favorite limit reached", message: "You can only have 5 favorites. Remove a favorite restaurant from your profile to add this one.")
            return
        } else {
            if let restaurant = searchResult?.getCurrentRestaurant() {
                restaurant.saveToCoreData(context: context, saveToFavorites: true)
            }
            self.favoritesBtn.setTitle("In favorites", for: .normal)
        }
        
        isRestaurantInFavorites.toggle()
    }
    
    //MARK: - Swipe
    @IBAction func restaurantCardSwipe(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else { return }
        
        let point = sender.translation(in: self.view)
        let xFromCenter = card.center.x - view.center.x
        
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        if xFromCenter == 0 {
            decisionIv.alpha = 0
            decisionIv.isHidden = true
        } else if xFromCenter > 0 {
            decisionIv.isHidden = false
            decisionIv.image = UIImage(systemName: "heart.circle.fill")
            decisionIv.tintColor = .systemBlue
        } else {
            decisionIv.isHidden = false
            decisionIv.image = UIImage(systemName: "xmark.circle.fill")
            decisionIv.tintColor = .systemRed
        }
        decisionIv.alpha = abs(xFromCenter) / view.center.x
        
        //done dragging
        if sender.state == .ended {
            
            //move off to the left
            if card.center.x < 75 {
                rejectRestaurant()
            } else if card.center.x > (view.frame.width - 75) {
                acceptRestaurant()
            } else {
                UIView.animate(withDuration: 0.2) {
                    card.center = self.view.center
                    self.decisionIv.alpha = 0
                    self.decisionIv.isHidden = true
                }
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if self.currentLocation == nil {
            self.currentLocation = location
        }
        //this gets called on alot so only fetch restaurants from a new location if that location is more than 300 meters away
        else if let currentLocation = self.currentLocation,
                  currentLocation.distance(from: location) < 300 {
            return
        }
        self.currentLocation = location
        
        getRestaurants(latitude: location.coordinate.latitude,
                       longitude: location.coordinate.longitude)
    }
}


extension UIViewController {
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okay)
        
        self.present(alert, animated: true, completion: nil)
    }
}
