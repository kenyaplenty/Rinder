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
    
    static func getRestaurants(latitude: Double,
                               longitude: Double,
                               start: Int = 0,
                               completionHandler: @escaping (_ searchResult: SearchResult) -> Void) {
        var urlString = "https://developers.zomato.com/api/v2.1/search?"
        urlString += "start=\(start)"
        urlString += "&lat=\(latitude)"
        urlString += "&lon=\(longitude)"
        urlString += "&radius=3218.69" //radius is in meters (2mi radius)
        urlString += "&category=2%2C8%2C9%2C10"
        urlString += "&sort=real_distance"
        urlString += "&order=desc"
        
        guard let restaurantUrl = URL(string: urlString) else {
            return completionHandler(SearchResult(from: nil))
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "user-key": apiKey
        ]
        
        AF.request(restaurantUrl, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let dictionary = value as? [String: Any],
                      response.response?.statusCode == 200,
                      let restaurantsJSONArray = dictionary["restaurants"] as? [AnyObject] else {
                    return completionHandler(SearchResult(from: nil))
                }
              
                var totalResults = 0
                if let totalPossible = dictionary["results_found"] as? Int {
                   totalResults = totalPossible
                }
                
                return completionHandler(SearchResult(from: restaurantsJSONArray,
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                      totalResults: totalResults))
              
            case .failure(let error):
                return completionHandler(SearchResult(from: nil))
            }
        }
    }
}
