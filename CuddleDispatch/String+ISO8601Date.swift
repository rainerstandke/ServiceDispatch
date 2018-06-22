//
//  String+ISO8603Date.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/17/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation


extension String {
	
	static func expirationString(with date: Date? = nil) -> String {
		// return iso string for next upcoming 9am or 9pm, depending on passed-in date
		// if called after 6 will jump over the next 9
		// meant for new requests that will live up to 15 hours, and at least 3
		
		let date = date ?? Date()
		
		let expDate = Calendar.nextHardDate(onHour: 9, withGracePeriod: 3, forDate: date)
		return isoFormattedString(from:expDate)
	}
	
	static func upcomingExpirationString(with inDate: Date? = nil) -> String {
		// meant for the next expiration, even as few as 3 hours away
		let inDate = inDate ?? Date()
		
		let date = Calendar.nextHardDate(onHour: 9, withGracePeriod: 0, forDate: inDate)
		return isoFormattedString(from:date)
	}
	
	
	static func isoFormattedString(from date: Date) -> String {
		let formatter = ISO8601DateFormatter()
		return formatter.string(from: date)
	}

	func date() -> Date? {
		return ISO8601DateFormatter().date(from: self)
	}
}
