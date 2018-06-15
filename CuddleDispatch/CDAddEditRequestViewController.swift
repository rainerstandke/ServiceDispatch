//
//  CDAddEditRequestViewController.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/12/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit
import Firebase

class CDAddEditRequestViewController: UIViewController {
	
	// TODO: UIStateRestore all fields
	
	var stationStrings = [String]()
	
	let dbRef = Database.database().reference()
	var editMode = AddEditMode.add
	
	var request: Request!

	@IBOutlet weak var stationPicker: UIPickerView!
	@IBOutlet weak var nurseTxtFld: UITextField!
	@IBOutlet weak var cpTxtFld: UITextField!
	@IBOutlet weak var ageGroupSegCtrl: UISegmentedControl!
	@IBOutlet weak var prioritySegCtrl: UISegmentedControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setUpTitleBar()
		
		loadPickerValues()
		
		if request == nil {
			print("making req")
			request = Request()
		}
		
		updateUIFromRequest()
    }
	
	func setUpTitleBar() {
		switch editMode {
		case .add:
			navigationItem.title = "Add New Request"
		case .edit:
			navigationItem.title = "Change Request"
		}
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUnwind))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddEdit))
	}

	func updateUIFromRequest() {
		
		let idx = stationStrings.index(of: request.station) ?? 0
		stationPicker.selectRow(idx, inComponent: 0, animated: false)
		
		nurseTxtFld.text = request.nurse
		cpTxtFld.text = request.carePartner
		
		// TODO: load segment titles from database?
		ageGroupSegCtrl.selectedSegmentIndex = UISegmentedControlNoSegment
		for idx in 0 ..< ageGroupSegCtrl.numberOfSegments {
			if request.ageGroup == ageGroupSegCtrl.titleForSegment(at: idx) {
				ageGroupSegCtrl.selectedSegmentIndex = idx
				break
			}
		}
		
		prioritySegCtrl.selectedSegmentIndex = UISegmentedControlNoSegment
		for idx in 0 ..< prioritySegCtrl.numberOfSegments {
			if request.priority == prioritySegCtrl.titleForSegment(at: idx) {
				prioritySegCtrl.selectedSegmentIndex = idx
				break
			}
		}
	}
	
	@objc func saveAndUnwind() {
		// called from left bar button
		saveRequest()
		performSegue(withIdentifier: "unwindFromAddEdit", sender: nil)
	}
	
	@objc func cancelAddEdit() {
		// called from right bar button, cancel
		performSegue(withIdentifier: "unwindFromAddEdit", sender: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// this gets called when we unwind from here back to table vu con
		print("segue: \(String(describing: segue))")
		
	}
	
	func saveRequest() {
		// TODO: don't overwrite existing requests, keep track of timestamp
		// probably by way of database key in Request, to indicate it's been loaded from db
		let newDbEntry = dbRef.child("requests").childByAutoId()
		
		var valueDict = [String: String]()
		
		let stationStr = stationStrings[stationPicker.selectedRow(inComponent: 0)]
		valueDict[K.DBFields.station] = stationStr
		
		valueDict[K.DBFields.nurse] = nurseTxtFld.text ?? ""
		valueDict[K.DBFields.carePartner] = cpTxtFld.text ?? ""
		valueDict[K.DBFields.ageGroup] = ageGroupSegCtrl.selectedTitle()
		valueDict[K.DBFields.priority] = prioritySegCtrl.selectedTitle()

		// TODO: leave date alone when editing, probably by way of database key in Request, to indicate it's been loaded from db, or only set date if is nil (in a newlycreated one)
		valueDict[K.DBFields.expirationDate] = expirationString()
		
		newDbEntry.updateChildValues(valueDict)
	}
	
	func expirationString() -> String {
		// make an ISO 8601 compliant date string to go into the database
		
		
		
		return self.expirationString(with: Date())
		
	}
	
	func expirationString(with date: Date) -> String {
		// return iso string for next upcoming 9am or 9pm, depending on passed-in date
		
		// TODO: write tests!
		
		let calendar = Calendar.init(identifier: .gregorian)
		
		let midNightTodayDateComps = DateComponents(calendar: calendar,
													year: calendar.component(.year, from: date),
													month: calendar.component(.month, from: date),
													day: calendar.component(.day, from: date),
													hour: 0,
													minute: 0,
													second: 0)
		
		var sixAmTodayDateComps = midNightTodayDateComps
		sixAmTodayDateComps.hour = 6
		let sixAmToday = calendar.date(from: sixAmTodayDateComps)
		
		var sixPmTodayDateComps = midNightTodayDateComps
		sixPmTodayDateComps.hour = 18
		let sixPmToday = calendar.date(from: sixPmTodayDateComps)
		
		var expirationDateComps = midNightTodayDateComps
		if date < sixAmToday! {
			expirationDateComps.hour = 9
		} else if date  > sixPmToday! {
			if let dayNr = expirationDateComps.day {
				expirationDateComps.day = dayNr + 1
				expirationDateComps.hour = 9
			} else {
				expirationDateComps.hour = 23 // just in case...
			}
		} else {
			expirationDateComps.hour = 21
		}
		
		let expDate = calendar.date(from: expirationDateComps) ?? Date.distantPast
		let formatter = ISO8601DateFormatter()
		let str = formatter.string(from: expDate)
		return str
	}
	
	
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//		print("prepare")
//		
//	}

}

extension CDAddEditRequestViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	func loadPickerValues() {
		// TODO: maybe change to 3 segments? Emergency Dept?
		dbRef.child("station-list").observeSingleEvent(of: .value) { [weak self] (snapShot) in
			if let stationListStr = snapShot.value as? String {
				let subStrings = stationListStr.split(separator: " ")
				self?.stationStrings = subStrings.map { return String($0) }
				self?.stationPicker.delegate = self
				self?.stationPicker.dataSource = self
			}
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return stationStrings.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return stationStrings[row]
	}
	
}


