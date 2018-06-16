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
		
		if let sectionArr = requestsStore[req.stationPrefix] {
			// section exists
			requestsStore[req.stationPrefix] = sectionArr + [req]
			// TODO: sort
		} else {
			// first in the section, just update the store
			requestsStore[req.stationPrefix] = [req]
		}
		
		if !sectionTitles.contains(req.stationPrefix) {
			sectionTitles.append(req.stationPrefix)
			sectionTitles.sort()
			
			self.reqTableVu.reloadData()
		} else {
			if let sectionIndex = sectionTitles.index(of: req.stationPrefix) {
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		print("segue: \(String(describing: segue))")
		print("sender: \(String(describing: sender))")
		
		if let identifier = segue.identifier,
			let dest = segue.destination as? CDAddEditRequestViewController {
			
			switch identifier {
			case K.SegueIdentifiers.addRequestSegue:
				dest.editMode = .add
			case K.SegueIdentifiers.editRequestSegue:
				dest.editMode = .edit
				// TODO: set dest.request!
			// dest.request = ... -> get from datasource
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
		
		let sectionKey = sectionTitles[indexPath.section]
		guard let reqArr = requestsStore[sectionKey] else { return reqCell }
		let reqest = reqArr[indexPath.row]

		reqCell.populate(from: reqest)
		
		return reqCell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return sectionTitles
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < sectionTitles.count {
			return sectionTitles[section]
		}
		return nil
	}
	
}
