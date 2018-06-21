//
//  Calendar+NextTime.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/20/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation


extension Calendar {
	
	static func nextHardDate(onHour clockHour: Int, withGracePeriod gracePeriod: Int, forDate date: Date, inTimeZone zone: TimeZone? = nil) -> Date {
		// for result 9am or 9pm, expect clockHour 9
		// the grace period is the the threshold after which we jump over the next hardTime.
		// e.g. grace period 3 makes for 6am or 6 pm
		// grace: 0 and hour: 6 give nearest future 6am or 6pm
		// time zone affects the datecomps, set to GMT for testing
		
		var calendar = Calendar.init(identifier: .gregorian)
		if let zone = zone {
			calendar.timeZone = zone
		}
		
		var dateComps = DateComponents(calendar: calendar,
													year: calendar.component(.year, from: date),
													month: calendar.component(.month, from: date),
													day: calendar.component(.day, from: date),
													hour: calendar.component(.hour, from: date),
													minute: 0,
													second: 0)
		
		let hour = dateComps.hour ?? 23
		switch hour {
		case ..<(clockHour - gracePeriod):
			dateComps.hour = clockHour
		case (clockHour - gracePeriod)..<(clockHour + 12 - gracePeriod):
			dateComps.hour = clockHour + 12
		case (clockHour + 12 - gracePeriod)...:
			if let dayNr = dateComps.day {
				dateComps.day = dayNr + 1
				dateComps.hour = clockHour
			} else {
				dateComps.hour = 23 // just in case...
			}
		default:
			dateComps.hour = 23
		}
		
		let expDate = calendar.date(from: dateComps) ?? Date.distantPast
		return expDate
	}
	
	static func nextHardDate(onHours hours:[Int], forDate date: Date? = nil, inTimeZone zone: TimeZone? = nil) -> Date {
		let effectiveDate = date ?? Date()
		let atSix = nextHardDate(onHour: 6, withGracePeriod: 0, forDate: effectiveDate, inTimeZone:zone)
		let atNine = nextHardDate(onHour: 9, withGracePeriod: 0, forDate: effectiveDate, inTimeZone:zone)
		return min(atNine, atSix)
	}
}
