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
	
	
	var dataSource: RequestDataSource?
	
	var sectionTitles = [String]()
	
	var requestsStorage = [String: [Request]]()
	
	lazy var dbRef: DatabaseReference = Database.database().reference()
	lazy var requestsRef: DatabaseReference = dbRef.child("requests")
	
	@IBOutlet weak var reqTableVu: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		reqTableVu.register(CDRequestTableViewCell.self, forCellReuseIdentifier: K.CellIDs.requestCellID)
		
		dataSource = RequestDataSource(query: dbRef, populateCell: { (tableView, indexPath, snapShot) -> UITableViewCell in
			
		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// TODO: filter for only not yet expired
		
		var reqArr = [Request]()
		requestsRef.observe(.value) { [unowned self] (snapshot) in
			let reqDict = snapshot.value as? [String: [String: String]] ?? [:]
			
			reqDict.forEach { (dbKey, valuesDict) in
				guard let newRequest = Request(dbKey: dbKey, valuesDict: valuesDict) else { return }
				reqArr.append(newRequest)
			}
			
			self.generateSectionInfo(for: reqArr)
			
			self.reqTableVu.reloadData()
		}
	}
	
	func generateSectionInfo(for requests: [Request]) {
		let prefixSet = Set(requests.map { $0.stationPrefix })
		print("prefixSet: \(String(describing: prefixSet))")
		
		
		
		for prefix in prefixSet {
			let arr = requests.filter { (request) -> Bool in
				return request.stationPrefix == prefix
			}
			
			requestsStorage[prefix] = arr
		}
		
		sectionTitles = requestsStorage.keys.sorted()
		
	}
	
	
	
	

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
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
				dest.request = Request()
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
		return requestsStorage.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.CellIDs.requestCellID)!
		print("indexPath: \(String(describing: indexPath))")
		
		let sectionKey = sectionTitles[indexPath.section]
		guard let reqArr = requestsStorage[sectionKey] else { return cell }
		let reqest = reqArr[indexPath.row]
		
		print("reqest: \(String(describing: reqest))\n\n")
		
		
		
		
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionTitles.count
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		// TODO: extract 'wards', e.g. 5E, 6W
		return sectionTitles
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < sectionTitles.count {
			return sectionTitles[section]
		}
		return nil
	}
	
}
