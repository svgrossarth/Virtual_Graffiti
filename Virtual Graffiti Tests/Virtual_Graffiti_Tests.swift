//
//  VirtualGraffitiTests.swift
//  VirtualGraffitiTests
//
//  Created by Elvis Alvarado on 1/26/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import XCTest
import CoreLocation
import Foundation
import CoreLocation
import Firebase
import SceneKit
@testable import Login
@testable import Database

class VirtualGraffitiTests: XCTestCase {
    var db : Database = Database()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        db = Database()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
}


// Database tests
extension VirtualGraffitiTests {
    func testSave() {
        //  1. given
        let location = CLLocation(latitude: 420, longtitude: 420)
        let userRootNode = SecondTierRoot()
        userRootNode.location = location
        
        // 2. when
        let retval = db.saveDrawing(userRootNode: userRootNode)
        
        // 3. then
        XCTAssertEqual(retval, true, "Database.saveDrawing(userRootNode : SecondTierRoot) returned false")
    }
    
    func testLoad() {
        // NOTE: Test AFTER testSave()
        // 1. given
        let location = CLLocation(latitude: 420, longtitude: 420)

        // 2. when
        db._drawPoints(location: location, drawFunction: { retrievedNodes in
            // 3. check
            for node in retrievedNodes {
                XCAssert(node.location, CLLocation(latitude: 420, longtitude: 420), "Retrieved test node location is not (420, 420)")
            }
            return
        })
    }
}
