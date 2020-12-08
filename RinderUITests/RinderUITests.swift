//
//  RinderUITests.swift
//  RinderUITests
//
//  Created by Francesco Prospato on 11/12/20.
//

import XCTest

class RinderUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

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
        app.launch()
        let profileButton = app.buttons["person.circle"]
        profileButton.tap()
        let logoutButton = app.buttons["Logout"]
        logoutButton.tap()
        XCTAssert(logoutButton.exists == false)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
