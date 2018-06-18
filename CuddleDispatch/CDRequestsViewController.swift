//
//  CDRequestsViewController.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/12/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit
import Firebase


class CDRequestsViewController: UIViewController {
	
	
	
	var sectionTitles = [String]()
	
	var requestsStore = [String: [Request]]()
	
	lazy var dbRef: DatabaseReference = Database.database().reference()
	lazy var requestsRef: DatabaseReference = dbRef.child("requests")
	var observedRequestRefHandles = [DatabaseHandle]() // effectively UNUSED
	
	@IBOutlet weak var reqTableVu: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRequest))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
		
		
		
		// TODO:
		// for expiring soon, look at local time -> after six? filter Requests for expiring in less than 3 hours
		// each time reqlist con comes on screen set a timer for the next time 6 rolls around (invalidate each time it disappears, too)
		
		// for database cleanup, a similar mechanism could call into google function to check if db has been cleaned -> at 9. store flag last clean time
		
		
		
		
		
		
		// clean out completely b/c we'll get all new requests, even if previously displayed
		requestsStore.removeAll()
		sectionTitles.removeAll()
		
		// NOTE: startingAt only works if ordered, and ordering seems to drop us down one nesting level
		let validQuery = requestsRef.queryOrdered(byChild: "expirationDate").queryStarting(atValue: String.expirationString(with: Date()))

		// this fires for local edits as well...
		observedRequestRefHandles.append(validQuery.observe(.childAdded, with: { [unowned self] (snapshot) in
			self.addRequestsSnapshot(snapshot)
		}))
		
		// fires for external edits
		observedRequestRefHandles.append(validQuery.observe(.childChanged, with: { (snapshot) in
			self.processExternalChange(in: snapshot)
		}))
		
		observedRequestRefHandles.append(validQuery.observe(.childRemoved, with: { (snapshot) in
			// TODO: implement model update
			print("removed snapshot: \(String(describing: snapshot))")
		}))
	}
	
	func addRequestsSnapshot(_ snapshot: DataSnapshot) {
		
		guard let req = Request(snapshot: snapshot) else { return }
		
		let prefix = req.stationPrefix // e.g. "5W"
		
		if let sectionArr = requestsStore[prefix] {
			// section exists
			requestsStore[prefix] = sectionArr + [req]
			// TODO: sort by priority, station
		} else {
			// first in the section, just update the store
			requestsStore[prefix] = [req]
		}
		
		updateSectionTitles(with: prefix)
	}
	
	func processExternalChange(in snapshot: DataSnapshot) {
		
		let valueDict = snapshot.valueDict()
		guard let prefix = valueDict["stationPrefix"] as? String else { print("no prefix in changed record"); return }
		guard let sectionArray = requestsStore[prefix] else { print("section not found"); return }
		let changedRequest = sectionArray.first { $0.dbKey == snapshot.key }
		changedRequest?.updateFrom(snapshot: snapshot)
		reloadTableDataInSectionTitled(prefix)
	}
	
//	func processRequestsSnapshots(_ snaps: [DataSnapshot]) {
//		// UNUSED (meant to deal with an array of all)
//		
//		// turn snapshots into Reqest objects
//		let reqArr = snaps.compactMap { (snapshot) -> Request? in
//			Request(snapshot: snapshot)
//		}
//		
//		// get unique stationPrefixes for the tableView sections
//		let prefixSet = Set(reqArr.map { $0.stationPrefix })
//		
//		// group requests by prefix & put in store
//		for prefix in prefixSet {
//			let arr = reqArr.filter { (request) -> Bool in
//				return request.stationPrefix == prefix
//			}
//			requestsStore[prefix] = arr
//		}
//		
//		sectionTitles = requestsStore.keys.sorted()
//	}

	override func viewWillDisappear(_ animated: Bool) {
		requestsRef.removeAllObservers()
		observedRequestRefHandles.removeAll()
	}
	

    // MARK: - Navigation

	@objc func addNewRequest() {
		performSegue(withIdentifier: K.SegueIdentifiers.addRequestSegue, sender: nil)
	}
	
	
	@IBAction func longPressed(_ lpGestRecog: UILongPressGestureRecognizer) {
		// long press to edit/change a request
		
		if lpGestRecog.state != .began { return }

		// make sure the long press comes from request tableView
		guard lpGestRecog.view == reqTableVu else { return }
		
		performSegue(withIdentifier: K.SegueIdentifiers.editRequestSegue, sender: lpGestRecog)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
        // for edit an existing Request, rely on sender being the longPressGesture that triggered the seque to find the Request
		// sender for edit/change is expected to be the long press recognizer on requestsTableView
		
		if let identifier = segue.identifier,
			let dest = segue.destination as? CDAddEditRequestViewController {
			
			switch identifier {
			case K.SegueIdentifiers.addRequestSegue:
				dest.editMode = .add
			case K.SegueIdentifiers.editRequestSegue:
				guard let lpGestRecog = sender as? UILongPressGestureRecognizer,
				let tableView = lpGestRecog.view as? UITableView else { break }
				
				let lpLocation = lpGestRecog.location(in: tableView)
				guard let idxPath = tableView.indexPathForRow(at: lpLocation) else { break }
				guard let request = requestForIndexPath(indexPath: idxPath) else { break }
				dest.request = request
				
				dest.editMode = .edit
			default:
				print("no segue for identifier: \(String(describing: identifier))")
			}
		}
	}
	
	@IBAction func unwindFromAddEdit(unwindSegue: UIStoryboardSegue){
		// this does nothing, but is needed to indicate it can be the target of an unwindSegue
		// will get called
	}
}


extension CDRequestsViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section >= sectionTitles.count { fatalError("section index too high") }
		
		let sectTitle = sectionTitles[section]
		guard let sectionArr = requestsStore[sectTitle] else { fatalError("section array not found") }
		return sectionArr.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.requestCellID)!
		
		guard let reqCell = cell as? CDRequestTableViewCell else { return cell }
		guard let request = requestForIndexPath(indexPath: indexPath) else { return cell }
		reqCell.populate(from: request)
		
		return reqCell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	// TODO: possibly add empty string after each title for spacing?? but adds lots of complexity elsewhere
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return sectionTitles
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < sectionTitles.count {
			return sectionTitles[section]
		}
		return nil
	}

	// helpers
	func requestForIndexPath(indexPath: IndexPath?) -> Request? {
		
		guard let indexPath = indexPath else { return nil }
		if indexPath.section > sectionTitles.count { return nil }
		
		let sectionKey = sectionTitles[indexPath.section]
		guard let reqArr = requestsStore[sectionKey] else { return nil }
		return reqArr[indexPath.row]
	}
	
	func updateSectionTitles(with title: String) {
		if !sectionTitles.contains(title) {
			sectionTitles.append(title)
			sectionTitles.sort()
			self.reqTableVu.reloadData()
		} else {
			reloadTableDataInSectionTitled(title)
//			if let sectionIndex = sectionTitles.index(of: title) {
//				self.reqTableVu.reloadSections(IndexSet(integer: sectionIndex) , with: .none)
//			} else {
//				self.reqTableVu.reloadData()
//			}
		}
	}
	
	func reloadTableDataInSectionTitled(_ title: String) {
		if let sectionIndex = sectionTitles.index(of: title) {
			self.reqTableVu.reloadSections(IndexSet(integer: sectionIndex) , with: .none)
		} else {
			self.reqTableVu.reloadData()
		}
	}
}
