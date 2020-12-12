//
//  RinderUITests.swift
//  RinderUITests
//
//  Created by Francesco Prospato on 11/12/20.
//

import XCTest

class RinderUITests: XCTestCase {

    override func setUpWithError() throws {
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testSwipeLeft() throws{
        let app = XCUIApplication()
        app.launch()
        app.swipeLeft()
        XCTAssertFalse( app.staticTexts["BJ\'s"].exists)
    }
    
    func testSwipeRight() throws {
        let app = XCUIApplication()
        app.launch()
        app.swipeRight()
        XCTAssertFalse( app.staticTexts["BJ\'s"].exists)
    }
    
    func testMenuButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        let menu = app.buttons["View Menu"]
        XCTAssert(menu.exists)
    }
    

    func testSaveRestaurantsAppear() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["My Restaurants"].tap()
        XCTAssert(app.staticTexts["Saved Restaurants"].exists)
    }
    
    
    func testInvalidRemoveSavedRestaurant() throws {
        let app = XCUIApplication()
        app.launch()
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        app.cells.staticTexts["BJ\'s"].swipeLeft()
        XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
    }
    
    func testValidRemoveSavedRestaurant() throws{
        let app = XCUIApplication()
        app.launch()
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        app.cells.staticTexts["BJ\'s"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.cells.staticTexts["BJ\'s"].exists)
    }
    
    func testFavoriteRestaurant() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
            app.buttons["person.circle"].tap()
            XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
        }
    }
    
    //func testInvalidFavoriteRemoval() throws {
        //let app = XCUIApplication()
        //app.launch()
        //let favoriteButton =  app.buttons["Add to Favorites"]
        //if(favoriteButton.exists){
            //favoriteButton.tap()
            //app.buttons["person.circle"].tap()
            //app.cells.staticTexts["BJ\'s"].swipeLeft()
            //XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
        //} else {
            //app.buttons["person.circle"].tap()
            //app.cells.staticTexts["BJ\'s"].swipeLeft()
            //XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
        //}
    //}
    
    func testValidFavoriteRemoval() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.buttons["person.circle"].tap()
        app.cells.staticTexts["BJ\'s"].swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.cells.staticTexts["BJ\'s"].exists)
    }


    func testInvalidEmail() throws {
        let app = XCUIApplication()
        app.launch()
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("***1**4@gmail.com")
        app.keyboards.buttons["Search"].tap()
        XCTAssert(app.cells.count == 0)
    }


    func testUserSearch() throws {
        let app = XCUIApplication()
        app.launch()
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("cam@gmail.com")
        app.keyboards.buttons["Search"].tap()
        let profileName = app.cells.staticTexts["Cam Com"]
        XCTAssert(profileName.exists)
    }


    func testNonUserSearch() throws {
        let app = XCUIApplication()
        app.launch()
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("kgp2111@columbia.edu")
        app.keyboards.buttons["Search"].tap()
        XCTAssert(app.cells.count == 0)
    }
    
    func testAddFavorite() throws {
        let app = XCUIApplication()
        app.launch()
        for n in 0...5 {
            let favoriteButton = app.buttons["Add to Favorites"]
            if(favoriteButton.exists){
                favoriteButton.tap()
            }
         
            app.swipeRight()
        }
        let okButton = app.buttons["OK"]
        if(okButton.exists){
            okButton.tap()
        }
        app.buttons["person.circle"].tap()
        XCTAssert(app.cells.count == 5)
    }
    
    func testFaceOffMatch() throws {
        let app = XCUIApplication()
        app.launch()
        for n in 0...4 {
            let favoriteButton = app.buttons["Add to Favorites"]
            if(favoriteButton.exists){
                favoriteButton.tap()
            }
            app.swipeRight()
        }
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("A")
        app.keyboards.buttons["Search"].tap()
        app.cells.staticTexts["Cam Com"].tap()
        XCTAssert(app.cells.count > 0)
    }
    
    func testFaceOffNoMatch() throws {
        let app = XCUIApplication()
        app.launch()
        for n in 0...4 {
            let favoriteButton = app.buttons["Add to Favorites"]
            if(favoriteButton.exists){
                favoriteButton.tap()
            }
            app.swipeRight()
        }
        let searchButton = app.buttons["Search"]
        searchButton.tap()
        let search = app.searchFields["Email"]
        search.tap()
        app.typeText("A")
        app.keyboards.buttons["Search"].tap()
        app.cells.staticTexts["Fake User"].tap()
        XCTAssert(app.staticTexts["No restaurants in common."].exists)
    }
    
    func testFavoriteFromSave() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["person.circle"].tap()
        if(app.cells.staticTexts["BJ\'s"].exists){
            app.cells.staticTexts["BJ\'s"].swipeLeft()
            app.buttons["Delete"].tap()
        }
        app.buttons["Close"].tap()
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        let restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.swipeUp()
        }
        restaurant.swipeRight()
        app.buttons["Favorite"].tap()
        if(restaurant.images["Fav Star Iv"].exists){
            app.buttons["Close"].tap()
            app.buttons["person.circle"].tap()
            XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
        }
    }
    
    func testValidFavoriteRemove() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        let restaurant = app.cells.staticTexts["BJ\'s"]
        restaurant.swipeRight()
        app.buttons["Unfavorite"].tap()
        if(!(restaurant.images["Fav Star Iv"].exists)){
            app.buttons["Close"].tap()
            app.buttons["person.circle"].tap()
            XCTAssertFalse(app.cells.staticTexts["BJ\'s"].exists)
        }
    }
    
    func testInValidFavoriteRemove() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        let restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.swipeUp()
        }
        restaurant.swipeRight()
        if((restaurant.images["Fav Star Iv"].exists)){
            app.buttons["Close"].tap()
            app.buttons["person.circle"].tap()
            XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
        }
    }
    
    func testInValidFavoriteRemoveTap() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.swipeRight()
        app.buttons["My Restaurants"].tap()
        let restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.swipeUp()
        }
        restaurant.tap()
        if((restaurant.images["Fav Star Iv"].exists)){
            if(restaurant.exists){
                app.buttons["Close"].tap()
                app.buttons["person.circle"].tap()
                XCTAssert(app.cells.staticTexts["BJ\'s"].exists)
            }
        }
    }
    
    func testInvalidFavoriteRemoveTap() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to Favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.buttons["person.circle"].tap()
        let restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.swipeUp()
        }
        restaurant.tap()
        XCTAssert(restaurant.exists)
    }
    
    func testFavoriteNotWithSave() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["My Restaurants"].tap()
        var restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.swipeUp()
            if(restaurant.exists){
                restaurant.swipeLeft()
                app.buttons["Delete"].tap()
                app.buttons["Close"].tap()
            } else {
                app.buttons["Close"].tap()
            }
        } else {
            restaurant.swipeLeft()
            app.buttons["Delete"].tap()
            app.buttons["Close"].tap()
        }
        
        let unfavoriteButton = app.buttons["In Favorites"]
        if(unfavoriteButton.exists){
            app.buttons["person.circle"].tap()
            let restaurant = app.cells.staticTexts["BJ\'s"]
            if(restaurant.exists){
                restaurant.swipeLeft()
                app.buttons["Delete"].tap()
                app.buttons["Close"].tap()
            }
            if(unfavoriteButton.exists){
                unfavoriteButton.tap()
            }
        }
        let favoriteButton = app.buttons["Add to favorites"]
        favoriteButton.tap()
        app.buttons["My Restaurants"].tap()
        restaurant = app.cells.staticTexts["BJ\'s"]
        if(!restaurant.exists){
            app.buttons["Close"].tap()
            app.buttons["person.circle"].tap()
            restaurant = app.cells.staticTexts["BJ\'s"]
            XCTAssert(restaurant.exists)
        }
    }
    
    func testInFavoritesButtonRemovesFavorite() throws {
        let app = XCUIApplication()
        app.launch()
        let favoriteButton = app.buttons["Add to favorites"]
        if(favoriteButton.exists){
            favoriteButton.tap()
        }
        app.buttons["person.circle"].tap()
        var restaurant = app.cells.staticTexts["BJ\'s"]
        if(restaurant.exists){
            app.buttons["Close"].tap()
            let unfavoriteButton = app.buttons["In Favorites"]
            if(unfavoriteButton.exists){
                unfavoriteButton.tap()
                app.buttons["person.circle"].tap()
                restaurant = app.cells.staticTexts["BJ\'s"]
                XCTAssertFalse(restaurant.exists)
            }
        }
    }
    
    
    


    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
