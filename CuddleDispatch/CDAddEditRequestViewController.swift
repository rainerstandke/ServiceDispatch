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

	@IBOutlet weak var stationPicker: UIPickerView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		switch editMode {
		case .add:
			navigationItem.title = "Add New Request"
		case .edit:
			navigationItem.title = "Change Request"
		}
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(performBackSegue))

		loadPickerValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@objc func performBackSegue() {
		// TODO:
		print("todo")
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


