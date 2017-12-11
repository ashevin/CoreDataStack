//
//  NSPredicate+ExtensionsTests.swift
//  CoreDataStackTests
//
//  Created by Avi Shevin on 27/11/2017.
//  Copyright © 2017 Avi Shevin. All rights reserved.
//

import XCTest
import CoreDataStack

class NSPredicate_ExtensionsTests: XCTestCase {
    let testArray: NSArray = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_equals() {
        let testValue = 3

        let f = testArray.filtered(using: NSPredicate(with: [ "SELF": testValue ]))

        XCTAssertEqual(testValue, f.first as? Int)
    }

    func test_contains() {
        let testValue = [ 3 ]

        let f = testArray.filtered(using: NSPredicate(with: [ "SELF": testValue ]))

        XCTAssertEqual(testValue.first, f.first as? Int)
    }

    func test_between_and_including() {
        let range = 5...7

        let f = testArray.filtered(using: NSPredicate(with: [ "SELF": range ]))

        XCTAssertEqual(range.count, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
        XCTAssertEqual(f[2] as? Int, 7)
    }

    func test_between() {
        let range = 5..<7

        let f = testArray.filtered(using: NSPredicate(with: [ "SELF": range ]))

        XCTAssertEqual(range.count, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
    }

    func test_or_with_conditions() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]).or([ "SELF": 6 ])

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(2, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
    }

    func test_or_with_predicates() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]).or(NSPredicate(format: "SELF == 6"))

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(2, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
    }

    func test_and_with_conditions() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]).and([ "SELF": [5, 6] ])

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
    }

    func test_and_with_predicates() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]).and(NSPredicate(format: "SELF IN %@", [5, 6]))

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
    }

    func test_not() {
        let predicate = NSPredicate(with: [ "SELF": 0..<9 ]).not()

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 9)
    }

    func test_or_operator_with_conditions() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]) || [ "SELF": 6 ]

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(2, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
    }

    func test_or_operator_with_predicates() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]) || NSPredicate(with:[ "SELF": 6 ])

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(2, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
        XCTAssertEqual(f[1] as? Int, 6)
    }

    func test_and_operator_with_conditions() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]) && [ "SELF": [5, 6] ]

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
    }

    func test_and_operator_with_predicates() {
        let predicate = NSPredicate(with: [ "SELF": 5 ]) && NSPredicate(with: [ "SELF": [5, 6] ])

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 5)
    }

    func test_not_operator() {
        let predicate = !NSPredicate(with: [ "SELF": 0..<9 ])

        let f = testArray.filtered(using: predicate)

        XCTAssertEqual(1, f.count)
        XCTAssertEqual(f[0] as? Int, 9)
    }
}
