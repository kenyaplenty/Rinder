//
//  HomeVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import CoreData
import GoogleSignIn
import CoreLocation
import SafariServices


class HomeVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet weak var errorLbl: UILabel!
    
    //restaurant details
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var cuisineLbl: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    
    //buttons
    @IBOutlet weak var leftIv: UIImageView!
    @IBOutlet weak var rightIv: UIImageView!
    @IBOutlet weak var savedBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    
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
    
    // Variables for unit tests
    var savedToCoreData = false
    var nextRestaurantCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getUserLocation()
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
        
        errorLbl.text = "No more restaurants"
        errorLbl.textAlignment = .center
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
    }
    
    //MARK: - Getting/Setting the restaurant
    
    private func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func getRestaurants(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if fetchingRestaurants { return }
        
        //show loading
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        print("here")
        
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
        }
    }
    
    //fill in restaurant info
    private func updateViewWithRestaurant(restaurant: Restaurant) {
        backView.isHidden = false
        self.errorLbl.isHidden = true
        
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
    
    @objc func rejectTap() {
        nextRestaurant()
    }
    
    @objc func acceptTap() {
        if let restaurant = searchResult?.getCurrentRestaurant() {
            restaurant.saveToCoreData(context: context)
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
    
    @IBAction func logOutBtnTap(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        signedInUser = nil
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        viewController.modalPresentationStyle = .currentContext
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
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
        
        getRestaurants(latitude: location.coordinate.latitude,
                       longitude: location.coordinate.longitude)
    }
}
