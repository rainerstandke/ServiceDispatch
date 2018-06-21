//
//  Request.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/13/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation
import Firebase

class Request: NSObject {
	
	
	// TODO: add databaseKey optional, to indicate editing existing record, and to target resave
	
	/* NOTE: properties are depended upon to be Strings ONLY */
	
	var dbKey: String // TODO: make optional to use as new? flag??
	var station: String
	var nurse: String
	var carePartner: String
	var ageGroup: String
	var priority: String
	var expirationDate: String? // set when first created, not updated when edited
	var stationPrefix: String
	var statusString: String
	
	init(dbKey: String, station: String, nurse: String, carePartner: String, ageGroup: String, priority: String, statusString: String) {
		self.dbKey = dbKey
		self.station = station
		self.nurse = nurse
		self.carePartner = carePartner
		self.ageGroup = ageGroup
		self.priority = priority
		self.statusString = statusString
		
		self.stationPrefix = station.components(separatedBy: "-").first ?? ""
	}
	
	
	init?(snapshot: DataSnapshot) {
		// this expects a snapshot for one individual request
		
		let dict = snapshot.valueDict()
		
		self.dbKey = snapshot.key
		
		guard let station = dict["station"]  as? String else { return nil }
		self.station = station

		guard let nurse = dict["nurse"]  as? String else { return nil }
		self.nurse = nurse

		guard let carePartner = dict["carePartner"]  as? String else { return nil }
		self.carePartner = carePartner

		guard let ageGroup = dict["ageGroup"]  as? String else { return nil }
		self.ageGroup = ageGroup

		guard let priority = dict["priority"]  as? String else { return nil }
		self.priority = priority

		guard let statusString = dict["statusString"]  as? String else { return nil }
		self.statusString = statusString
		
		if let expStr = dict["expirationDate"] as? String {
			self.expirationDate = expStr
		}
		
		self.stationPrefix = ""
		super.init()
		updateStationPrefix()
	}
	
//	init?(dbKey: String, valuesDict:[String: String]) {
//		// used when downloading items 'in bulk'
//		guard let station = valuesDict["station"] else { return nil }
//		guard let nurse = valuesDict["nurse"] else { return nil }
//		guard let carePartner = valuesDict["carePartner"] else { return nil }
//		guard let ageGroup = valuesDict["ageGroup"] else { return nil }
//		guard let priority = valuesDict["priority"] else { return nil }
//		guard let statusString = valuesDict["statusString"] else { return nil }
//
//		self.dbKey = dbKey
//		self.station = station
//		self.nurse = nurse
//		self.carePartner = carePartner
//		self.ageGroup = ageGroup
//		self.priority = priority
//		self.statusString = statusString
//
//		self.stationPrefix = ""
//		super.init()
//		updateStationPrefix()
//	}
//
//	convenience override init() {
//		self.init(dbKey: "", station: "", nurse: "", carePartner: "", ageGroup: "", priority: "", statusString: "")
//	}
	
	// MARK: -
	
	func updateFrom(snapshot: DataSnapshot) {
		let dict = snapshot.valueDict()
		
		if let station = dict["station"]  as? String {
			self.station = station
		}
		if let nurse = dict["nurse"]  as? String {
			self.nurse = nurse
		}
		if let carePartner = dict["carePartner"]  as? String {
			self.carePartner = carePartner
		}
		if let ageGroup = dict["ageGroup"]  as? String {
			self.ageGroup = ageGroup
		}
		if let priority = dict["priority"]  as? String {
			self.priority = priority
		}
		if let statusString = dict["statusString"]  as? String {
			self.statusString = statusString
		}
		if let expirationDate = dict["expirationDate"]  as? String {
			self.expirationDate = expirationDate
		}
		
		updateStationPrefix()
	}
	
	// MARK: -
	
	func updateStationPrefix() {
		stationPrefix = type(of: self).stationPrefixFromStation(from: station)
	}
	
	static func stationPrefixFromStation(from: String) -> String {
		return from.components(separatedBy: "-").first ?? ""
	}
	
	func isExpiring() -> Bool {
		guard let expStr = self.expirationDate else { return false }
		guard let expDate = expStr.date() else { return false }
		// is there more than 3 hours between now and the expiration date?
		return expDate.timeIntervalSinceNow < 10800
	}
	
	// MARK: -
	
	override var description: String {
		return makeDesciption()
	}

	func makeDesciption() -> String {
		var str = "\n" + station + " " + priority
		str.append(" " + ageGroup + " " + nurse)
		str.append(" " + carePartner + " " + statusString)
		if let expD = expirationDate {
			str.append(" " + expD)
		}
		str.append(" " + dbKey)
		return str
	}
}
