//
//  RestaurantHelper.swift
//  Rinder
//
//  Created by Francesco Prospato on 11/12/20.
//

import Foundation
import Alamofire

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
                               long: Double,
                               completionHandler: @escaping (_ restaurants: [Restaurant]) -> Void) {
        guard let url = URL(string: "https://developers.zomato.com/api/v2.1/search") else {
            return completionHandler([])
        }

        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "user-key": apiKey,
            "lat": "\(lat)",
            "lon": "\(long)",
            "radius": "300", //radius is in meters
            "sort" : "real_distance"
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
    var imageURL: String = ""
    var url: String = ""
    var address: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var cuisines: String = ""
    var price_range: String = ""
    
    init(from jsonDict: NSDictionary) {
        if let id = jsonDict["id"] as? String {
            self.id = id
        }
        
        if let name = jsonDict["name"] as? String {
            self.name = name
        }
        
        if let featured_image = jsonDict["featured_image"] as? String {
            self.imageURL = featured_image
        }
        
        if let url = jsonDict["url"] as? String {
            self.url = url
        }
        
        if let location = jsonDict["location"] as? NSDictionary {
            if let address = location["address"] as? String {
                self.address = address
            }
            
            if let lat = location["latitude"] as? String {
                self.latitude = lat
            }
            
            if let lon = location["longitude"] as? String {
                self.longitude = lon
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
