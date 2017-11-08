//
//  RandomizerTests.swift
//  RandomMeTests
//
//  Created by Joe on 07.11.17.
//

import XCTest
@testable import RandomMe

class RandomizerTests: XCTestCase {
	
	var sampleChar: [String]!
	var randomizer: Randomizer!
	
    override func setUp() {
        super.setUp()
		
		sampleChar = ["A", "B", "C"]
		
		randomizer = Randomizer(items: sampleChar,
								onChanges: nil,
								onComplete: nil)
    }
    
    override func tearDown() {
        // gets called after the invocation of each test method in the class
        super.tearDown()
		randomizer = nil
    }
	
	func testRandomizerEndWithEmptyInput() {
		randomizer.reloadItems([])
		
		var completed: Bool = false
		let expected = XCTestExpectation(description: "expected")
		randomizer.completion = { _ in
			expected.fulfill()
			completed = true
		}
		
		randomizer.randomize()
		
		_ = XCTWaiter.wait(for: [expected], timeout: 3.0)
		
		XCTAssert(completed)
	}
	
	
	func testRandomizerSubResults() {
		
		var subResults: [String] = []
		
		randomizer.changing = {
			(str) in
			if let _str = str as? String {
				subResults.append(_str)
			}
		}
		
		let expected = XCTestExpectation(description: "expected")
		randomizer.completion = { _ in expected.fulfill() }
		
		// run
		randomizer.randomize()
		
		// wait for completion
		_ = XCTWaiter.wait(for: [expected], timeout: 6.0)
		
		// assert
		XCTAssertGreaterThan(subResults.count, 0, "no element added")
	}
	
    
    func testRandomizerResult() {
		
		var result: String?
		let expected = XCTestExpectation(description: "expected")
		
		randomizer.completion = { (str) in
			result = str as? String
			expected.fulfill()
		}
		
		// execute
		randomizer.randomize()
		
		// wait for completion
		_ = XCTWaiter.wait(for: [expected], timeout: 6.0)
		
		// assert
        XCTAssertNotNil(result, "empty result")
    }
    
}
