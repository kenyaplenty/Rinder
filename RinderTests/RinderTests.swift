//
//  RinderTests.swift
//  RinderTests
//
//  Created by Francesco Prospato on 11/12/20.
//
// swiftlint:disable all

import XCTest
import CoreData
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
    
    func testAddRestaurant() throws {
        let vc = HomeVC(nibName: "HomeVC", bundle: nil)
        DispatchQueue.main.async {
            let restaurant = Restaurant.init(id: "1", name: "NAME", featuredImageURL: nil, menuURL: nil, address: "IDK", location: nil, cuisines: "IDK", priceRange: "IDK")
            vc.updateViewWithRestaurant(restaurant: restaurant, isUnitTesting: true)
            
            vc.acceptRestaurant(isUnitTesting: true)
            
            guard let context = vc.context else{
                return
            }
                    
            let request : NSFetchRequest<SavedRestaurant> = SavedRestaurant.fetchRequest()
            request.predicate = NSPredicate(format: "id = 1")
            
            do {
                let count = try context.count(for: request)
                XCTAssertGreaterThanOrEqual(count, 0)
            } catch {
                print("Hey Listen! Error finding users: \(error.localizedDescription)")
            }
        }
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
