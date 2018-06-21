//
//  String+ISO8603Date.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/17/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation


extension String {
	
	static func expirationString() -> String {
		// make an ISO 8601 compliant date string to go into the database
		return self.expirationString(with: Date())
	}
	
	static func expirationString(with date: Date) -> String {
		// return iso string for next upcoming 9am or 9pm, depending on passed-in date
		
		// TODO: write tests!
		
		let calendar = Calendar.init(identifier: .gregorian)
		
		let midNightTodayDateComps = DateComponents(calendar: calendar,
													year: calendar.component(.year, from: date),
													month: calendar.component(.month, from: date),
													day: calendar.component(.day, from: date),
													hour: 0,
													minute: 0,
													second: 0)
		
		var sixAmTodayDateComps = midNightTodayDateComps
		sixAmTodayDateComps.hour = 6
		let sixAmToday = calendar.date(from: sixAmTodayDateComps)
		
		var sixPmTodayDateComps = midNightTodayDateComps
		sixPmTodayDateComps.hour = 18
		let sixPmToday = calendar.date(from: sixPmTodayDateComps)
		
		var expirationDateComps = midNightTodayDateComps
		if date < sixAmToday! {
			expirationDateComps.hour = 9
		} else if date  > sixPmToday! {
			if let dayNr = expirationDateComps.day {
				expirationDateComps.day = dayNr + 1
				expirationDateComps.hour = 9
			} else {
				expirationDateComps.hour = 23 // just in case...
			}
		} else {
			expirationDateComps.hour = 21
		}
		
		let expDate = calendar.date(from: expirationDateComps) ?? Date.distantPast
		
		
		
		
		
		let formatter = ISO8601DateFormatter()
		let str = formatter.string(from: expDate)
		return str
	}
	
	func date() -> Date? {
		return ISO8601DateFormatter().date(from: self)
	}
}
