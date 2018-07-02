//
//  Constants.swift
//  ServiceDispatch
//
//  Created by Rainer Standke on 6/13/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation

enum AddEditMode {
	case add
	case edit
}

struct K {
	struct SegueIdentifiers {
		static let addRequestSegue = "addRequestSegue"
		static let editRequestSegue = "editRequestSegue"
	}
	struct DBFields {
		static let nurse = "nurse"
		static let carePartner = "carePartner"
		static let station = "station"
		static let stationPrefix = "stationPrefix"
		static let ageGroup = "ageGroup"
		static let priority = "priority"
		static let expirationDate = "expirationDate"
		static let statusString = "statusString"
	}
	
	struct CellIDs {
		static let requestCellID = "requestCellID"
		static let requestGroupHeaderCellID = "requestGroupHeaderCellID"
	}
	
	struct UDefs {
		static let nextPruneDate = "nextPruneDate"
	}
}
