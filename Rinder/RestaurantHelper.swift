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
}
