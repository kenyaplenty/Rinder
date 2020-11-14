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
    
    //MARK: - Variables
    private var locationManager = CLLocationManager()
    private var fetchingRestaurants = false
    
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
    }
    
    private func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func getRestaurants(lat: CLLocationDegrees, long: CLLocationDegrees) {
        if !fetchingRestaurants {
            fetchingRestaurants = true
            RestaurantHelper.getRestaurants(lat: lat.binade,
                                            long: long.binade) { (restuarants) in
                print("got it!")
                self.fetchingRestaurants = false
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        getRestaurants(lat: location.coordinate.latitude,
                       long: location.coordinate.longitude)
    }
}
