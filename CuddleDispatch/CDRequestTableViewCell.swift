//
//  CDRequestTableViewCell.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/15/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit

class CDRequestTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	@IBOutlet weak var stationLabel: UILabel!
	@IBOutlet weak var priorityLabel: UILabel!
	@IBOutlet weak var ageGroupLabel: UILabel!
	@IBOutlet weak var nurseNameLabel: UILabel!
	@IBOutlet weak var cpNameLabel: UILabel!
	@IBOutlet weak var statusView: StatusView!
	
	func populate(from request: Request) {
		stationLabel.text = request.station
		priorityLabel.text = request.priority
		ageGroupLabel.text = request.ageGroup
		nurseNameLabel.text = request.nurse
		cpNameLabel.text = request.carePartner
		statusView.setStatusWith(request.statusString)
	}
}
