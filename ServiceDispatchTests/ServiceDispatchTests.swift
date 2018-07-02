//
//  ServiceDispatchTests.swift
//  ServiceDispatchTests
//
//  Created by Rainer Standke on 6/20/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import XCTest


class ServiceDispatchTests: XCTestCase {
	
	var dateFormatter = DateFormatter()
	
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	
	func testCloserOfTwoTimes() {
		let parms = (firstHour: 6, secondHour: 9, expectedResult: ["hour 0: 2001-01-01 06:00:00 +0000", "hour 1: 2001-01-01 06:00:00 +0000", "hour 2: 2001-01-01 06:00:00 +0000", "hour 3: 2001-01-01 06:00:00 +0000", "hour 4: 2001-01-01 06:00:00 +0000", "hour 5: 2001-01-01 06:00:00 +0000", "hour 6: 2001-01-01 09:00:00 +0000", "hour 7: 2001-01-01 09:00:00 +0000", "hour 8: 2001-01-01 09:00:00 +0000", "hour 9: 2001-01-01 18:00:00 +0000", "hour 10: 2001-01-01 18:00:00 +0000", "hour 11: 2001-01-01 18:00:00 +0000", "hour 12: 2001-01-01 18:00:00 +0000", "hour 13: 2001-01-01 18:00:00 +0000", "hour 14: 2001-01-01 18:00:00 +0000", "hour 15: 2001-01-01 18:00:00 +0000", "hour 16: 2001-01-01 18:00:00 +0000", "hour 17: 2001-01-01 18:00:00 +0000", "hour 18: 2001-01-01 21:00:00 +0000", "hour 19: 2001-01-01 21:00:00 +0000", "hour 20: 2001-01-01 21:00:00 +0000", "hour 21: 2001-01-02 06:00:00 +0000", "hour 22: 2001-01-02 06:00:00 +0000", "hour 23: 2001-01-02 06:00:00 +0000"])
		
		
		let zone = TimeZone(abbreviation: "GMT")
		var dateStrs = [String]()
		
		(0 ... 23).forEach { hour in
			let inDate = Date.init(timeIntervalSinceReferenceDate: Double(hour) * 3600.0)
			let outDate = Calendar.nextHardDate(onHours: [parms.firstHour, parms.secondHour], forDate: inDate, inTimeZone: zone)
			XCTAssertNotNil(outDate, "expected date")
			dateStrs.append("hour \(hour): " + outDate!.description)
		}
		
		let passing = parms.expectedResult == dateStrs
		if !passing {
			print(" expected:\n\(parms.expectedResult.joined(separator: "\n"))\n got:\n\(dateStrs.joined(separator: "\n"))")
		}
		XCTAssert(passing, "fail closerOfTwoTimes with \(parms.firstHour) and \(parms.secondHour)")
	}
	
	
    func testThresholdTimes() {
		
		let parms = [(at: 9, with: 3, expectedResult: ["hour 0: 2001-01-01 09:00:00 +0000", "hour 1: 2001-01-01 09:00:00 +0000", "hour 2: 2001-01-01 09:00:00 +0000", "hour 3: 2001-01-01 09:00:00 +0000", "hour 4: 2001-01-01 09:00:00 +0000", "hour 5: 2001-01-01 09:00:00 +0000", "hour 6: 2001-01-01 21:00:00 +0000", "hour 7: 2001-01-01 21:00:00 +0000", "hour 8: 2001-01-01 21:00:00 +0000", "hour 9: 2001-01-01 21:00:00 +0000", "hour 10: 2001-01-01 21:00:00 +0000", "hour 11: 2001-01-01 21:00:00 +0000", "hour 12: 2001-01-01 21:00:00 +0000", "hour 13: 2001-01-01 21:00:00 +0000", "hour 14: 2001-01-01 21:00:00 +0000", "hour 15: 2001-01-01 21:00:00 +0000", "hour 16: 2001-01-01 21:00:00 +0000", "hour 17: 2001-01-01 21:00:00 +0000", "hour 18: 2001-01-02 09:00:00 +0000", "hour 19: 2001-01-02 09:00:00 +0000", "hour 20: 2001-01-02 09:00:00 +0000", "hour 21: 2001-01-02 09:00:00 +0000", "hour 22: 2001-01-02 09:00:00 +0000", "hour 23: 2001-01-02 09:00:00 +0000"]), (at: 6, with: 0, expectedResult: ["hour 0: 2001-01-01 06:00:00 +0000", "hour 1: 2001-01-01 06:00:00 +0000", "hour 2: 2001-01-01 06:00:00 +0000", "hour 3: 2001-01-01 06:00:00 +0000", "hour 4: 2001-01-01 06:00:00 +0000", "hour 5: 2001-01-01 06:00:00 +0000", "hour 6: 2001-01-01 18:00:00 +0000", "hour 7: 2001-01-01 18:00:00 +0000", "hour 8: 2001-01-01 18:00:00 +0000", "hour 9: 2001-01-01 18:00:00 +0000", "hour 10: 2001-01-01 18:00:00 +0000", "hour 11: 2001-01-01 18:00:00 +0000", "hour 12: 2001-01-01 18:00:00 +0000", "hour 13: 2001-01-01 18:00:00 +0000", "hour 14: 2001-01-01 18:00:00 +0000", "hour 15: 2001-01-01 18:00:00 +0000", "hour 16: 2001-01-01 18:00:00 +0000", "hour 17: 2001-01-01 18:00:00 +0000", "hour 18: 2001-01-02 06:00:00 +0000", "hour 19: 2001-01-02 06:00:00 +0000", "hour 20: 2001-01-02 06:00:00 +0000", "hour 21: 2001-01-02 06:00:00 +0000", "hour 22: 2001-01-02 06:00:00 +0000", "hour 23: 2001-01-02 06:00:00 +0000"])]
		
		parms.forEach {
			let result = checkTimesUsing(at: $0.at, with: $0.with, expectedResult: $0.expectedResult)
			if !result.passed {
				print(" expected:\n\($0.expectedResult.joined(separator: "\n"))\n got:\n\(result.generated.joined(separator: "\n"))")
			}
			
			XCTAssert(result.passed, "test failed with at:\($0.at), with: \($0.with)")
		}
	}
	
	func checkTimesUsing(at: Int, with: Int, expectedResult: [String]) -> (passed: Bool, generated: [String]) {
		let zone = TimeZone(abbreviation: "GMT")
		var dateStrs = [String]()
		(0 ... 23).forEach { hour in
			let inDate = Date.init(timeIntervalSinceReferenceDate: Double(hour) * 3600.0)
			let outDate = Calendar.nextHardDate(onHour: at, withGracePeriod: with, forDate: inDate, inTimeZone: zone)
			dateStrs.append("hour \(hour): " + outDate.description)
		}
		
		return (passed: dateStrs == expectedResult, generated: dateStrs)
	}
}


