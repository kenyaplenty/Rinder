//
//  RinderUITests.swift
//  RinderUITests
//
//  Created by Francesco Prospato on 11/12/20.
//

import XCTest

class RinderUITests: XCTestCase {

    override func setUpWithError() throws {
        //sign in
        let app = XCUIApplication()
        app.launch()
        let signInBtn = app.buttons[".i"]
        signInBtn.tap()
        
        //click allow for location tracking
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowBtn = springboard.buttons["Allow While Using App"]
        if allowBtn.exists {
            allowBtn.tap()
        }
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogout() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        let profileButton = app.buttons["person.circle"]
        profileButton.tap()
        let logoutButton = app.buttons["Logout"]
        logoutButton.tap()
        XCTAssert(logoutButton.exists == false)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //func testUserSearch() throws {
        //let app = XCUIApplication()
        //let searchButton = app.buttons["Search"]
        //searchButton.tap()
        //let search = app.searchFields["Email"]
        //search.tap()
        //app.typeText("cam@gmail.com")
        //app.keyboards.buttons["Search"].tap()
        //let profileName = app.cells.staticTexts["Cam Com"]
        //XCTAssert(profileName.exists)
    //}
    
    func testNonUserSearch() throws {
        let app = XCUIApplication()
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("kgp2111@columbia.edu")
        app.keyboards.buttons["Search"].tap()
        XCTAssert(app.cells.count == 0)
    }
    
    //func testInvalidEmail() throws {
        //let app = XCUIApplication()
        //let searchButton = app.buttons["Search"]
        //searchButton.tap()
        //let search = app.searchFields["Email"]
        //search.tap()
        //app.typeText("***1**4@gmail.com")
        //app.keyboards.buttons["Search"].tap()
        //XCTAssert(app.cells.count == 0)
    //}
    
    func testSwipeLeft() throws{
        let app = XCUIApplication()
        app.swipeLeft()
        XCTAssertFalse(app.staticTexts["BJ\'s"].exists)
    }
    
    func testSwipeRight() throws {
        let app = XCUIApplication()
        app.swipeRight()
        XCTAssertFalse(app.staticTexts["BJ\'s"].exists)
    }
    
    //func testSaveRestaurant() throws {
        //let app = XCUIApplication()
        //app.swipeRight()
        //app.buttons["My Restaurants"].tap()
        //XCTAssert(app.staticTexts["BJ\'s"].exists)
    //}
    
    //func testRestaurantRunOut() throws {
        //let app = XCUIApplication()
        //for n in 0...21 {
            //app.swipeRight()
        //}
        //XCTAssert(app.staticTexts["No more restaurants"].exists)
    //}
    
    //func testInvalidRemoveSavedRestaurant() throws {
        //let app = XCUIApplication()
        //app.swipeRight()
        //app.buttons["My Restaurants"].tap()
        //app.cells.staticTexts["Cafe Torre"].swipeLeft()
        //XCTAssert(app.staticTexts["Cafe Torre"].exists)
    //}
    
    //func testValidRemoveSavedRestaurant() throws{
        //let app = XCUIApplication()
        //app.swipeRight()
        //app.buttons["My Restaurants"].tap()
        //app.swipeUp()
        //app.cells.staticTexts["BJ\'s"].swipeLeft()
        //app.buttons["Delete"].tap()
        //XCTAssertFalse(app.cells.staticTexts["BJ\'s"].exists)
    //}
    
    //func testFavoriteRestaurant() throws {
        //let app = XCUIApplication()
        //app.buttons["Add to Favorites"].tap()
        //app.buttons["person.circle"].tap()
        //XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
    //}
    
    //func testInvalidFavoriteRemoval() throws {
        //let app = XCUIApplication()
        //app.buttons["person.circle"].tap()
        //app.cells.staticTexts["BJ\'s"].swipeLeft()
        //XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
    //}
    
    //func testValidFavoriteRemoval() throws {
        //let app = XCUIApplication()
        //app.buttons["person.circle"].tap()
        //app.cells.staticTexts["BJ\'s"].swipeLeft()
        //app.buttons["Delete"].tap()
        //XCTAssertFalse(app.cells.staticTexts["BJ\'s"].exists)
    //}

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
