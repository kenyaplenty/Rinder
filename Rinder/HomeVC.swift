//
//  HomeVC.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    
    //restaurant details
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var cuisineLbl: UILabel!
    
    //buttons
    @IBOutlet weak var leftIv: UIImageView!
    @IBOutlet weak var rightIv: UIImageView!
    
    
    
    //MARK: - Variables
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    private var fetchingRestaurants = false
    private var restaurants = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getUserLocation()
    }
    
    private func setupView() {
        fromLbl.text = "Restaurants near"
        fromLbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        fromLbl.textAlignment = .center
        
        locationLbl.textAlignment = .center
        locationLbl.text = "Current Location"
        locationLbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        titleLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    
    private func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func getRestaurants(lat: CLLocationDegrees, long: CLLocationDegrees) {
        if fetchingRestaurants { return }
        
        fetchingRestaurants = true
        RestaurantHelper.getRestaurants(lat: Double(lat),
                                        lon: Double(long)) { (restuarantsFound) in
            self.restaurants = restuarantsFound
            self.fetchingRestaurants = false
            
            if let restaurant = self.restaurants.first {
                self.updateViewWithRestaurant(restaurant: restaurant)
            }
        }
    }
    
    private func updateViewWithRestaurant(restaurant: Restaurant) {
        DispatchQueue.main.async { [self] in
            
            self.titleLbl.text = restaurant.name
            
            if let location = self.currentLocation, let restaurantLocation = restaurant.location {
                let distanceInMiles = String(format: "%.02f", location.distance(from: restaurantLocation)/1609.344)
                self.distanceLbl.text = "\(distanceInMiles) mi away"
            }
            
            self.cuisineLbl.text = "Cuisines: \(restaurant.cuisines)"
            
            self.setRestaurantImage(url: restaurant.imageURL)
        }
    }
    
    private func setRestaurantImage(url: URL?) {
        guard let url = url else { return }
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.restaurantImage.image = image
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
        
        getRestaurants(lat: location.coordinate.latitude,
                       long: location.coordinate.longitude)
    }
}
