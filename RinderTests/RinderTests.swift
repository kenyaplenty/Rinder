//
//  RinderTests.swift
//  RinderTests
//
//  Created by Francesco Prospato on 11/12/20.
//
// swiftlint:disable all

import XCTest
@testable import Rinder

class RinderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Test getRestaurants
    func testGetRestaurants() throws {
        let vc = HomeVC()
        vc.getRestaurants(latitude: 40.7128, longitude: 74.0060) // passes New York coordinates
        XCTAssertTrue(vc.fetchingRestaurants)
    }
    
    func testAcceptTap() throws {
        let vc = HomeVC()
        vc.getRestaurants(latitude: 40.7128, longitude: 74.0060)
        XCTAssertTrue(vc.fetchingRestaurants)
        
        vc.acceptTap()
        XCTAssertEqual(vc.nextRestaurantCalled, true)
    }
    
    func testRejectTap() throws {
        let vc = HomeVC()
        vc.getRestaurants(latitude: 40.7128, longitude: 74.0060)
        XCTAssertTrue(vc.fetchingRestaurants)
        
        vc.rejectTap()
        XCTAssertTrue(vc.nextRestaurantCalled)
    }
    
    // Test updateViewWithRestaurant
    //func testUpdateViewWithRestaurant() throws {
    //    let vc = HomeVC()
    //    let restaurant = Restaurant.init(name: "Potato", cuisines: "Thai")
    //    XCTAssertNotNil(restaurant)
    //    vc.updateViewWithRestaurant(restaurant: restaurant!)
    //    XCTAssertEqual(vc.titleLbl.text, restaurant?.name)
    //}
}
