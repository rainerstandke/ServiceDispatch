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
	
	
	// TODO: organize / order this class
	
	
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
			store[prefix] = sectionArr
		} else {
			// first in the section, just update the store
			store[prefix] = [req]
		}
	}
	
	// take a snapshot, find the corresponding request, update it, move sections if needed
	// return affected section titles
	func updateWithSnapshot(_ snapshot: DataSnapshot) -> [String] {
		// (could use snapshot.stationPrefix to get section, right?)
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
	
	func deleteWithSnapshot(_ snapshot: DataSnapshot) -> RemoteRemovalResult {
		
		// (could use snapshot.stationPrefix to get section, right?)
		guard let tbdReq = requestWithKey(snapshot.key) else { return .failed }
		let prefix = tbdReq.stationPrefix
		
		remove(request: tbdReq, from: prefix)
		
		guard let subArr = store[prefix] else { return .failed }
		if subArr.count == 0 {
			store.removeValue(forKey: prefix)
			let newSections = store.keys.sorted()
			return .needFullReloadWithNewSections(newSections)
		}
		
		return .needPartialReloadOf([prefix])
	}
	
	// result of a deletion that happened remotely
	enum RemoteRemovalResult {
		case needPartialReloadOf([String])
		case needFullReloadWithNewSections([String])
		case failed
	}
	
	func deleteIn(section: String, at idx: Int) -> LocalRemovalResult {
		guard var sectionArr = store[section] else { return .failed }
		guard idx < sectionArr.count else { return .failed }
		
		let request = sectionArr[idx]
		
		sectionArr.remove(at: idx)
		store[section] = sectionArr
		
		if sectionArr.count == 0 {
			store.removeValue(forKey: section)
			let newSections = store.keys.sorted()
			return .needFullReloadWithNewSections(sectionTitles: newSections, removedKey: request.dbKey)
		}
		
		return .needPartialReloadOf(sectionTitle: section, removedKey: request.dbKey)
	}
	
	// result of a deletion that was triggrered by the user, locally
	enum LocalRemovalResult {
		case needPartialReloadOf(sectionTitle: String, removedKey: String)
		case needFullReloadWithNewSections(sectionTitles: [String], removedKey: String)
		case failed
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
		store[section] = sectionArr
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
