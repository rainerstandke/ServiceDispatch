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
	
	var request: Request?

	@IBOutlet weak var stationPicker: UIPickerView!
	@IBOutlet weak var nurseTxtFld: UITextField!
	@IBOutlet weak var cpTxtFld: UITextField!
	@IBOutlet weak var ageGroupSegCtrl: UISegmentedControl!
	@IBOutlet weak var prioritySegCtrl: UISegmentedControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setUpTitleBar()
		prepPickerView()
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateUIFromRequest()
	}

	func updateUIFromRequest() {
		// only if we are updating / editing a pre-existing request
		guard let req = request else { return }
		
		let idx = AppDelegate.stationStrings.index(of: req.station) ?? 0
		stationPicker.selectRow(idx, inComponent: 0, animated: false)
		
		nurseTxtFld.text = req.nurse
		cpTxtFld.text = req.carePartner
		
		// TODO: load (ageGroup & priority) segment titles from database?
		ageGroupSegCtrl.selectedSegmentIndex = UISegmentedControlNoSegment
		for idx in 0 ..< ageGroupSegCtrl.numberOfSegments {
			if req.ageGroup == ageGroupSegCtrl.titleForSegment(at: idx) {
				ageGroupSegCtrl.selectedSegmentIndex = idx
				break
			}
		}
		
		prioritySegCtrl.selectedSegmentIndex = UISegmentedControlNoSegment
		for idx in 0 ..< prioritySegCtrl.numberOfSegments {
			if req.priority == prioritySegCtrl.titleForSegment(at: idx) {
				prioritySegCtrl.selectedSegmentIndex = idx
				break
			}
		}
	}
	
	@objc func saveAndUnwind() {
		// called from left bar button
		saveRequest() // write UI values into new or existing Request
		performSegue(withIdentifier: "unwindFromAddEdit", sender: nil)
	}
	
	@objc func cancelAddEdit() {
		// called from right bar button, cancel
		performSegue(withIdentifier: "unwindFromAddEdit", sender: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// this gets called when we unwind from here back to table vu con
	}
	
	func saveRequest() {
		// build up values from UI no matter what...
		var valueDict = [String: String]()
		
		let stationStr = stationStrings[stationPicker.selectedRow(inComponent: 0)]
		valueDict[K.DBFields.station] = stationStr
		valueDict[K.DBFields.stationPrefix] = Request.stationPrefixFromStation(from: stationStr)
			
		valueDict[K.DBFields.nurse] = nurseTxtFld.text ?? ""
		valueDict[K.DBFields.carePartner] = cpTxtFld.text ?? ""
		valueDict[K.DBFields.ageGroup] = ageGroupSegCtrl.selectedTitle()
		valueDict[K.DBFields.priority] = prioritySegCtrl.selectedTitle()
		
		if request != nil {
			// dealing with pre-existing request = edit / change
			// leave expiration alone
			
			guard let req = request else { fatalError("could not modify Request") }
			dbRef.child("requests").child(req.dbKey).updateChildValues(valueDict)
		} else {
			// make new entry
			valueDict[K.DBFields.expirationDate] = String.expirationString() // add new expiration
			valueDict[K.DBFields.statusString] = CuddleStatus.none.rawValue
			
			let newDbEntry = dbRef.child("requests").childByAutoId()
			newDbEntry.updateChildValues(valueDict)
		}
	}
}

extension CDAddEditRequestViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	
	func prepPickerView() {
		stationStrings = AppDelegate.stationStrings
		stationPicker.delegate = self
		stationPicker.dataSource = self
		
		// TODO: maybe change to 3 segments? Emergency Dept?
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


