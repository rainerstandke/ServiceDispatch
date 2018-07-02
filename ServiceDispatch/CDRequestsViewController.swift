//
//  CDRequestsViewController.swift
//  ServiceDispatch
//
//  Created by Rainer Standke on 6/12/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit
import Firebase

class CDRequestsViewController: UIViewController {
	
	var sectionTitles = [String]()
	
	var store = RequestStore()
	
	lazy var dbRef: DatabaseReference = Database.database().reference()
	lazy var requestsRef: DatabaseReference = dbRef.child("requests")
	
	@IBOutlet weak var reqTableVu: UITableView!
	
	var refreshUITimer: Timer? {
		didSet {
			NSLog("timer set: \(String(describing: refreshUITimer))")
		}
	}
	
	// MARK: -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRequest))
		
		reqTableVu.rowHeight = UITableViewAutomaticDimension
		reqTableVu.estimatedRowHeight = 64
		
		NotificationCenter.default.addObserver(self, selector: #selector(setupView), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(tearDownView), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		
		
		
		
		// TODO: loose these 2:
		let tokenButton = UIButton(type: .roundedRect)
		tokenButton.frame = CGRect(x: 20, y: 80, width: 100, height: 30)
		tokenButton.setTitle("token", for: [])
		tokenButton.addTarget(self, action: #selector(logToken), for: .touchUpInside)
		view.addSubview(tokenButton)
		
		let pruneButton = UIButton(type: .roundedRect)
		pruneButton.frame = CGRect(x: 20, y: 160, width: 100, height: 30)
		pruneButton.setTitle("prune", for: [])
		pruneButton.addTarget(self, action: #selector(callPruneFunction), for: .touchUpInside)
		view.addSubview(pruneButton)
	}
	
	// TODO: loose this
	@objc func logToken(_ sender: Any?) {
		guard let user = Auth.auth().currentUser else { return }
		user.getIDToken { (str, err) in
			print("str: \(String(describing: str))")
			print("err: \(String(describing: err))")
			
		}
		user.getIDTokenResult(completion: { (authTokenRes, err) in
			print("authTokenRes: \(String(describing: authTokenRes))")
			print("err: \(String(describing: err))")
			print("authTokenRes?.token: \(String(describing: authTokenRes?.token))")
			print("authTokenRes?.claims: \(String(describing: authTokenRes?.claims))")
			print("authTokenRes?.signInProvider: \(String(describing: authTokenRes?.signInProvider))")
		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupView()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tearDownView()
	}
	
	@objc func setupView() {
		print("setup")
		// clear tableView data source, re-subscribe to online database updates, which will yield add-events for all entries right away, even if previously displayed
		store.resetStore()
		
		sectionTitles.removeAll()
		
		refreshUITimer?.invalidate()
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			// delay 3.0 avoids double-firing
			// TODO: make this in the delayed block!
			guard let nextSixOrNine = Calendar.nextHardDate(onHours: [6, 9]) else { print("no next date"); return }
			let timeInterval = nextSixOrNine.timeIntervalSinceNow
			NSLog("timeInterval: \(String(describing: timeInterval))")
			self?.refreshUITimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] timer in
				NSLog("timer fires")
				// at 6 and 9, force refresh of db records. at 6 for expiring soon, at 9 for expired requests
				self?.requestsRef.removeAllObservers()
				self?.callPruneFunction()
				self?.setupView()
			}
		}
		
		// NOTE: startingAt only works if ordered, and ordering seems to drop us down one nesting level
		let query = requestsRef.queryOrdered(byChild: "expirationDate").queryStarting(atValue: String.upcomingExpirationString())
		
		query.observe(.childAdded, with: { [weak self] (snapshot) in
			print("childAdded") // TODO: loose x 3!
			// this fires for local and remote edits
			guard let req = Request(snapshot: snapshot) else { return }
			
			self?.store.addNewRequest(req)
			self?.updateSectionTitles(with: [req.stationPrefix])
		})
		
		query.observe(.childChanged, with: { [unowned self] (snapshot) in
			print("childChanged")
			// fires for external edits
			
			let affectedSectionTitles = self.store.updateWithSnapshot(snapshot)
			self.updateSectionTitles(with: affectedSectionTitles)
		})
		
		query.observe(.childRemoved, with: { [weak self] (snapshot) in
			print("childRemoved")
			// fires for external deletions
			guard let status = self?.store.deleteWithSnapshot(snapshot) else { return }
			
			switch status {
			case .failed:
				self?.reqTableVu.reloadData()
			case .needPartialReloadOf(let strs):
				strs.forEach { self?.reloadTableDataInSectionTitled($0) }
			case .needFullReloadWithNewSections(let strs):
				self?.sectionTitles = strs
				self?.reqTableVu.reloadData()
			}
		})
		
		reqTableVu.reloadData()
	}
	
	@objc func callPruneFunction() {
		
		// delete expired requests, calling a firebase function
		
		let uDefs = UserDefaults.standard
		
		if let nextPruneDate = uDefs.object(forKey: K.UDefs.nextPruneDate) as? Date {
			if nextPruneDate.timeIntervalSinceNow > 2 {
				// more than 2 secs left until next prune time
				print("not prune time yet: \(nextPruneDate.timeIntervalSinceNow)")
				return
			}
		}
		print("past time -> pruning")
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			// timer tends to fire early - delay prevents setting next prune time to something merely seconds away
			uDefs.set(Calendar.nextHardDate(onHours: [9]), forKey: K.UDefs.nextPruneDate)
		}
		
		guard let user = Auth.auth().currentUser else { return }
		user.getIDToken { (inTokenStr, err) in
			
			if let error  = err { print("getTokeError: \(error)"); return }
			
			guard let tokenStr = inTokenStr else { print("no token: \(String(describing: inTokenStr))"); return }
			
			let configuration = URLSessionConfiguration.ephemeral
			let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
			guard let url = URL(string: "https://us-central1-Servicedispatch-d4299.cloudfunctions.net/pruneExpiredRequests") else { print("url failure"); return }
			
			var request = URLRequest(url: url)
			request.addValue("Bearer " + tokenStr, forHTTPHeaderField: "Authorization")
			
			let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
				if let resp = response as? HTTPURLResponse {
					if resp.statusCode == 200 {
						print("pruned OK")
					} else {
						print("prune resp status: \(resp.statusCode)")
					}
				}
			})
			task.resume()
		}
	}
	
	@objc func tearDownView() {
		print("tearDownView")
		requestsRef.removeAllObservers()
		refreshUITimer?.invalidate()
	}

	// MARK: - Navigation for add / edit request
	
	@objc func addNewRequest() {
		// called from right nav item
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
		return store.countForSection(sectTitle)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.requestCellID)!
		
		guard let reqCell = cell as? CDRequestTableViewCell else { return cell }
		guard let request = requestForIndexPath(indexPath: indexPath) else { return cell }
		reqCell.populate(from: request)
		
		reqCell.statusChangeCallBack = { [unowned self] status, dbKey in
			
			guard let key = dbKey  else { print("no key"); return }
			guard let req = self.store.requestWithKey(key) else { print("no req from store"); return }
			
			if req.statusString == status.rawValue { print("redundant"); return }
			self.dbRef.child("requests").child(key).updateChildValues([K.DBFields.statusString:status.rawValue])
		}
		
		return reqCell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < sectionTitles.count {
			return sectionTitles[section]
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard indexPath.section < sectionTitles.count else { return }
		let removalResult = store.deleteIn(section: sectionTitles[indexPath.section], at: indexPath.row)
		
		switch removalResult {
		case .failed:
			return
		case .needFullReloadWithNewSections(sectionTitles: let strs, removedKey: let removedKey):
			requestsRef.child(removedKey).removeValue()
			self.sectionTitles = strs
			self.reqTableVu.reloadData()
			break
		case .needPartialReloadOf(sectionTitle: let str, removedKey: let removedKey):
			requestsRef.child(removedKey).removeValue()
			self.reloadTableDataInSectionTitled(str)
			break
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.requestGroupHeaderCellID) as? CDGroupHeaderTableViewCell else { return nil }
		guard section < sectionTitles.count else { return cell }
		cell.halfFloorLabel.text = sectionTitles[section]
		return cell.contentView
	}

	// helpers
	func requestForIndexPath(indexPath: IndexPath?) -> Request? {
		guard let indexPath = indexPath else { return nil }
		if indexPath.section > sectionTitles.count { return nil }
		
		let sectionKey = sectionTitles[indexPath.section]
		return store.requestInSection(sectionKey, at: indexPath.row)
	}
	
	func updateSectionTitles(with titles: [String]) {
		var sectionsNeedingReload = [String]()
		titles.forEach { (title) in
			if sectionTitles.contains(title) {
				sectionsNeedingReload.append(title)
			} else {
				sectionTitles.append(title)
				sectionTitles.sort()
				// TODO: check out if whole table reload is ever needed
			}
		}
		
		if sectionsNeedingReload.count > 0 {
			sectionsNeedingReload.forEach { (section) in
				reloadTableDataInSectionTitled(section)
			}
		} else {
			reqTableVu.reloadData()
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
