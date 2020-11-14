//
//  RinderTests.swift
//  RinderTests
//
//  Created by Francesco Prospato on 11/12/20.
//

import XCTest
import CoreLocation

@testable import Rinder

class RinderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //Check to see if we can get restaurants
    func getRestaurantTest() throws {
        //Columbia coordinates
        let location = CLLocation(latitude: CLLocationDegrees(40.8075), longitude: CLLocationDegrees(-73.9626))
        
        RestaurantHelper.getRestaurants(lat: location.coordinate.latitude,
                                        lon: location.coordinate.longitude) { (searchResult) in
            XCTAssertTrue(searchResult.successfulFetch)
            XCTAssertTrue(searchResult.restaurants.count > 0)
        }
    }

}
