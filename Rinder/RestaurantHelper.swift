//
//  RestaurantHelper.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import Foundation
import Alamofire
import CoreLocation

class RestaurantHelper {
    
    private static let apiKey = "8a0c5aa6e710c35ba61ebef8de744a60"
    
    //MARK: - Getters
    
    static func getCategories(completionHandler: @escaping (_ receivedCategories: Bool) -> Void) {
        
        guard let url = URL(string: "https://developers.zomato.com/api/v2.1/categories") else {
            return completionHandler(false)
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
             "user-key": apiKey
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? [String: Any], response.response?.statusCode == 200 else {
                    return completionHandler(false)
                }
                
                return completionHandler(true)
                
            case .failure(let error):
                return completionHandler(false)
            }
        }
    }
    
    static func getRestaurants(lat: Double,
                               lon: Double,
                               completionHandler: @escaping (_ restaurants: [Restaurant]) -> Void) {
        var urlString = "https://developers.zomato.com/api/v2.1/search?"
        urlString += "lat=\(lat)"
        urlString += "&lon=\(lon)"
        urlString += "&radius=3218.69" //radius is in meters (2mi radius)
        urlString += "&sort=real_distance"
        urlString += "&order=desc"
        
        guard let url = URL(string: urlString) else {
            return completionHandler([])
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "user-key": apiKey
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                var restaurants = [Restaurant]()
                
                guard let dictionary = value as? [String: Any],
                      response.response?.statusCode == 200,
                      let restaurantsJSON = dictionary["restaurants"] as? [AnyObject] else {
                    return completionHandler(restaurants)
                }
                
                for restaurantJSON in restaurantsJSON {
                    if let restaurantDict = restaurantJSON as? NSDictionary,
                       let restaurantDetailsDict = restaurantDict["restaurant"] as? NSDictionary {
                        restaurants.append(Restaurant(from: restaurantDetailsDict))
                    }
                }
                
                return completionHandler(restaurants)
                
            case .failure(let error):
                return completionHandler([])
            }
        }
    }
}

struct Restaurant {
    var id: String = ""
    var name: String = ""
    var imageURL: URL?
    var url: String = ""
    var address: String = ""
    var location: CLLocation?
    var cuisines: String = ""
    var price_range: String = ""
    
    init(from jsonDict: NSDictionary) {
        if let id = jsonDict["id"] as? String {
            self.id = id
        }
        
        if let name = jsonDict["name"] as? String {
            self.name = name
        }
        
        if let featuredImageString = jsonDict["featured_image"] as? String,
           let featuredImageURL = URL(string: featuredImageString){
            self.imageURL = featuredImageURL
        }
        
        if let url = jsonDict["url"] as? String {
            self.url = url
        }
        
        if let location = jsonDict["location"] as? NSDictionary {
            if let address = location["address"] as? String {
                self.address = address
            }
            
            if let latString = location["latitude"] as? String,
               let lat = Float(latString),
               let lonString = location["longitude"] as? String,
               let lon = Float(lonString) {
                self.location = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
            }
        }
        
        if let cuisines = jsonDict["cuisines"] as? String {
            self.cuisines = cuisines
        }
        
        if let price_range = jsonDict["price_range"] as? String {
            self.price_range = price_range
        }
    }
}
