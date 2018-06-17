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
	var observedRequestRefHandles = [DatabaseHandle]()
	
	@IBOutlet weak var reqTableVu: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRequest))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// TODO: filter for only not yet expired
		
		// clean out completely b/c we'll get all new notifs, even if previously displayed
		requestsStore.removeAll()
		sectionTitles.removeAll()
		
		observedRequestRefHandles.append(self.requestsRef.observe(.childAdded, with: { [unowned self] (snapshot) in
			self.addRequestsSnapshot(snapshot)
		}))
		
		observedRequestRefHandles.append(self.requestsRef.observe(.childChanged, with: { (snapshot) in
			print("changed snapshot: \(String(describing: snapshot))")
		}))
		
		observedRequestRefHandles.append(self.requestsRef.observe(.childRemoved, with: { (snapshot) in
			print("removed snapshot: \(String(describing: snapshot))")
		}))
		print("observedRequestRefHandles: \(String(describing: self.observedRequestRefHandles))")
	}
	
	func addRequestsSnapshot(_ snapshot: DataSnapshot) {
		
		guard let req = Request(snapshot: snapshot) else { return }
		
		let prefix = req.stationPrefix // e.g. "5W"
		
		if let sectionArr = requestsStore[prefix] {
			// section exists
			requestsStore[prefix] = sectionArr + [req]
			// TODO: sort
		} else {
			// first in the section, just update the store
			requestsStore[prefix] = [req]
		}
		
		if !sectionTitles.contains(prefix) {
			sectionTitles.append(prefix)
			sectionTitles.sort()
			self.reqTableVu.reloadData()
		} else {
			if let sectionIndex = sectionTitles.index(of: prefix) {
				self.reqTableVu.reloadSections(IndexSet(integer: sectionIndex) , with: .none)
			} else {
				self.reqTableVu.reloadData()
			}
		}
	}
	
	func processRequestsSnapshots(_ snaps: [DataSnapshot]) {
		// UNUSED (meant to deal with an array of all)
		
		// turn snapshots into Reqest objects
		let reqArr = snaps.compactMap { (snapshot) -> Request? in
			Request(snapshot: snapshot)
		}
		
		// get unique stationPrefixes for the tableView sections
		let prefixSet = Set(reqArr.map { $0.stationPrefix })
		
		// group requests by prefix & put in store
		for prefix in prefixSet {
			let arr = reqArr.filter { (request) -> Bool in
				return request.stationPrefix == prefix
			}
			requestsStore[prefix] = arr
		}
		
		sectionTitles = requestsStore.keys.sorted()
	}

	override func viewWillDisappear(_ animated: Bool) {
		requestsRef.removeAllObservers()
		observedRequestRefHandles.removeAll()
	}
	

    // MARK: - Navigation

	@objc func addNewRequest() {
		performSegue(withIdentifier: K.SegueIdentifiers.addRequestSegue, sender: nil)
	}
	
	
	@IBAction func longPressed(_ lpGestRecog: UILongPressGestureRecognizer) {
		if lpGestRecog.state != .began {
			return
		}

		guard let tableView = lpGestRecog.view as? UITableView,
			tableView == reqTableVu else { return }
		performSegue(withIdentifier: K.SegueIdentifiers.editRequestSegue, sender: lpGestRecog)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
        // for edit an existing Request, rely on sender being the longPressGesture that triggered the seque to find the Request
		
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
	
	func requestForIndexPath(indexPath: IndexPath?) -> Request? {
		
		guard let indexPath = indexPath else { return nil }
		if indexPath.section > sectionTitles.count { return nil }
		
		let sectionKey = sectionTitles[indexPath.section]
		guard let reqArr = requestsStore[sectionKey] else { return nil }
		return reqArr[indexPath.row]
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	// TODO: possibly add empty string after each title for spacing?? but adds lots of complexity elsewhere
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return sectionTitles
	}
	
	// helper
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < sectionTitles.count {
			return sectionTitles[section]
		}
		return nil
	}
}
