//
//  CDRequestTableViewCell.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/15/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit

class CDRequestTableViewCell: UITableViewCell {

	@IBOutlet weak var stationLabel: UILabel!
	@IBOutlet weak var priorityLabel: UILabel!
	@IBOutlet weak var ageGroupLabel: UILabel!
	@IBOutlet weak var nurseNameLabel: UILabel!
	@IBOutlet weak var cpNameLabel: UILabel!
	
	@IBOutlet weak var expiringView: UIImageView!
	
	var dbKey: String?
	
	func populate(from request: Request) {
		stationLabel.text = request.station
		priorityLabel.text = request.priority
		ageGroupLabel.text = request.ageGroup
		nurseNameLabel.text = request.nurse
		cpNameLabel.text = request.carePartner
		
		self.dbKey = request.dbKey
		
		if statusString() != request.statusString {
			setStatusWith(request.statusString)
		}
		
		changeStatusDisplay(from: status)
		
		expiringView.isHidden = !request.isExpiring()
	}

	
	// MARK: - Status Mechanism
	// note: could move this logic into custom view with own nib, like this: https://medium.com/theappspace/swift-custom-uiview-with-xib-file-211bb8bbd6eb
	
	@IBOutlet weak var rightButton: UIButton!
	@IBOutlet weak var leftButton: UIButton!
	
	public var status = CuddleStatus.none {
		didSet(oldValue) {
			changeStatusDisplay(from: oldValue)
		}
	}
	
	// execute upon status change, set from outside
	public var statusChangeCallBack: ((_ status: CuddleStatus, _ dbKey: String?) -> ())? = nil
	
	@IBAction func leftImgTapped(sender: UIButton) {
		if status == .none || status == .concluded {
			status = .inProgress
			statusChangeCallBack?(status, dbKey)
		}
	}

	@IBAction func rightImgTapped(sender: UIButton) {
		if status == .inProgress {
			status = .concluded
			statusChangeCallBack?(status, dbKey)
		}
	}
	
	public func setStatusWith(_ string: String) {
		guard let newStatus = CuddleStatus.init(rawValue: string) else {
			print("status string NG")
			return
		}
		status = newStatus
	}
	
	public func statusString() -> String {
		return status.rawValue
	}
	
	func changeStatusDisplay(from: CuddleStatus) {
		switch status {
		case .none:
			leftButton.tintAdjustmentMode = .normal
			leftButton.tintColor = self.tintColor
			if from == .none {
				rightButton.setImage(nil, for: .normal)
			} else {
				rightButton.setImage(UIImage.init(named: "Done.pdf"), for: .normal)
				rightButton.tintColor = UIColor.black
			}
		case .inProgress:
			rightButton.setImage(UIImage.init(named: "Out.pdf"), for: .normal)
			rightButton.tintColor = self.tintColor
			leftButton.tintAdjustmentMode = .dimmed
		case .concluded:
			leftButton.tintAdjustmentMode = .normal
			rightButton.tintColor = UIColor.black
			rightButton.setImage(UIImage.init(named: "Done.pdf"), for: .normal)
		}
	}
}


enum CuddleStatus: String {
	case none // original, before first cuddle
	case inProgress
	case concluded // after first cuddle conclusion
}



