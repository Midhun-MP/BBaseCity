//
//  CityTests.swift
//  CityTests
//
//  Created by Midhun on 19/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//

import XCTest
@testable import City

class CityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // Loads Correct City Data
    func testLoadCityData()
    {
        // Loading Correct data
        XCTAssertTrue(!CTUtility.loadCityFromJSONFile(fileName: CTConstants.fileName).isEmpty)
    }
    
}
