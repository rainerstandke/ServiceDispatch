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

		let expDate = Calendar.nextHardDate(onHour: 9, withGracePeriod: 3, forDate: date)
		let formatter = ISO8601DateFormatter()
		let str = formatter.string(from: expDate)
		return str
	}
	
	func date() -> Date? {
		return ISO8601DateFormatter().date(from: self)
	}
}
