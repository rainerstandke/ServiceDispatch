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
	var station: String {
		didSet(newValue) {
			print("newValue: \(String(describing: newValue))")
			stationPrefix = station.components(separatedBy: "-").first ?? ""
		}
	}
	var nurse: String
	var carePartner: String
	var ageGroup: String
	var priority: String
	var expirationDate: String? // set when first created, not updated when edited
	//	var inProgress: Bool // TODO: implement
	var stationPrefix: String
	
	init(dbKey: String, station: String, nurse: String, carePartner: String, ageGroup: String, priority: String) {
		self.dbKey = dbKey
		self.station = station
		self.nurse = nurse
		self.carePartner = carePartner
		self.ageGroup = ageGroup
		self.priority = priority
		
		self.stationPrefix = station.components(separatedBy: "-").first ?? ""
	}
	
	
	init?(snapshot: DataSnapshot) {
		// this assumes a snapshot for the individual item
		guard let dict = snapshot.value as? [String:Any] else { return nil }
		
		guard let dbKey  = dict["dbKey"] as? String  else { return nil }
		guard let station = dict["station"]  as? String else { return nil }
		guard let nurse = dict["nurse"]  as? String else { return nil }
		guard let carePartner = dict["carePartner"]  as? String else { return nil }
		guard let ageGroup = dict["ageGroup"]  as? String else { return nil }
		guard let priority = dict["priority"]  as? String else { return nil }
		
		self.dbKey = dbKey
		self.station = station
		self.nurse = nurse
		self.carePartner = carePartner
		self.ageGroup = ageGroup
		self.priority = priority
	
		self.stationPrefix = station.components(separatedBy: "-").first ?? ""
	}
	
	init?(dbKey: String, valuesDict:[String: String]) {
		// used when downloading items 'in bulk'
		guard let station = valuesDict["station"] else { return nil }
		guard let nurse = valuesDict["nurse"] else { return nil }
		guard let carePartner = valuesDict["carePartner"] else { return nil }
		guard let ageGroup = valuesDict["ageGroup"] else { return nil }
		guard let priority = valuesDict["priority"] else { return nil }
		
		self.dbKey = dbKey
		self.station = station
		self.nurse = nurse
		self.carePartner = carePartner
		self.ageGroup = ageGroup
		self.priority = priority
	
		self.stationPrefix = station.components(separatedBy: "-").first ?? ""
	}
	
	convenience override init() {
		self.init(dbKey: "", station: "", nurse: "", carePartner: "", ageGroup: "", priority: "")
	}
	
	override var description: String {
		return makeDesciption()
	}

	func makeDesciption() -> String {
		var str = "\n" + station + " " + priority
		str.append(" " + ageGroup + " " + nurse)
		str.append(" " + carePartner)
		if let expD = expirationDate {
			str.append(" " + expD)
		}
		str.append(" " + dbKey)
		return str
	}
}
