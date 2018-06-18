//
//  RequestStore.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/18/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//


/* holds all requests */

import Foundation
import Firebase


class RequestStore {
	
	// store is dict of array of Requests, where the keys are the section titles in the table view
	private var store = [String: [Request]]()
	
	func resetStore() {
		store = [String: [Request]]()
	}
	
	// sorts by 3 criteria...
	private let requestSortFunction = { (req1: Request, req2: Request) -> Bool in
		return (req1.station, req1.priority, req1.ageGroup) < (req2.station, req2.priority, req2.ageGroup)
	}
	
	func addNewRequest(_ req: Request) {
		let prefix = req.stationPrefix // e.g. "5W"
		
		addRequest(req, toSection: prefix)
	}
	
	private func addRequest(_ req: Request, toSection prefix: String) {
		if var sectionArr = store[prefix] {
			// section exists
			sectionArr.append(req)
			sectionArr.sort(by: requestSortFunction)
		} else {
			// first in the section, just update the store
			store[prefix] = [req]
		}
	}
	
	// take a snapshot, find the corresponding request, update it, move sections if needed
	// return affected section titles
	func updateWithSnapshot(_ snapshot: DataSnapshot) -> [String] {
		
		guard let changedReq = requestWithKey(snapshot.key) else { return [] }
		let oldPrefix = changedReq.stationPrefix
		
		changedReq.updateFrom(snapshot: snapshot)
		
		var affectedSectionStrs = [oldPrefix]
		let newPrefix = changedReq.stationPrefix
		
		if oldPrefix != newPrefix,
			var newSectionArray = store[newPrefix] {
			remove(request: changedReq, from: oldPrefix)
			newSectionArray.append(changedReq)
			affectedSectionStrs.append(newPrefix)
		}
		
		store[oldPrefix]?.sort(by: requestSortFunction)
		
		return affectedSectionStrs
	}
	
	private func requestWithKey(_ dbKey: String) -> Request? {
		for section in store.keys {
			if let req = store[section]?.first(where: { $0.dbKey == dbKey }) {
				return req
			}
		}
		return nil
	}
	
	private func remove(request: Request, from section: String) {
		guard var sectionArr = store[section] else { return }
		guard let idx = sectionArr.index(of: request) else { return }
		sectionArr.remove(at: idx)
	}
	
	// MARK: for tableView queries
	
	func countForSection(_ section: String) -> Int {
		return store[section]?.count ?? 0
	}

	func requestInSection(_ section: String, at idx: Int) -> Request? {
		guard let sectArr = store[section] else { return nil }
		if idx < sectArr.count {
			return sectArr[idx]
		}
		return nil
	}
}
