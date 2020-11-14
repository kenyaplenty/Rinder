//
//  HomeVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
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
    
    
    
    //MARK: - Variables
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    private var fetchingRestaurants = false
    private var searchResult: SearchResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getUserLocation()
    }
    
    private func setupView() {
        fromLbl.text = "Restaurants near"
        fromLbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        fromLbl.textAlignment = .center
        
        backView.layer.cornerRadius = 16
        backView.layer.masksToBounds = true
        
        restaurantImage.layer.cornerRadius = 16
        restaurantImage.layer.masksToBounds = true
        restaurantImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        locationLbl.textAlignment = .center
        locationLbl.text = "Current Location"
        locationLbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl.text = ""
        distanceLbl.text = ""
        cuisineLbl.text = ""
        
        errorLbl.text = "No more restaurants"
        errorLbl.textAlignment = .center
        errorLbl.isHidden = true
        
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

    private func getRestaurants(lat: CLLocationDegrees, long: CLLocationDegrees) {
        if fetchingRestaurants { return }
        
        //show loading
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        fetchingRestaurants = true
        RestaurantHelper.getRestaurants(lat: Double(lat),
                                        lon: Double(long)) { (searchResultFound) in
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
            
            self.cuisineLbl.text = "Cuisines: \(restaurant.cuisines)"
            
            if let imageURL = restaurant.featuredImageURL {
                self.setRestaurantImage(url: imageURL)
            } else {
                self.restaurantImage.image = nil
            }
            
            self.menuBtn.isHidden = restaurant.menuURL == nil
        }
    }
    
    //fetch the image from the internet and put it on
    private func setRestaurantImage(url: URL) {
        //show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.restaurantImage.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
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
    
    @objc private func rejectTap() {
        nextRestaurant()
    }
    
    @objc private func acceptTap() {
        nextRestaurant()
    }
    
    @objc private func nextRestaurant() {
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
        
        getRestaurants(lat: location.coordinate.latitude,
                       long: location.coordinate.longitude)
    }
}
