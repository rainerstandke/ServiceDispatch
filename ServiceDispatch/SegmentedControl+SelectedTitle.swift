//
//  SegmentedControl+SelectedTitle.swift
//  ServiceDispatch
//
//  Created by Rainer Standke on 6/14/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation

extension UISegmentedControl {
	func selectedTitle() -> String {

		var selIdx = selectedSegmentIndex
		if selIdx == UISegmentedControlNoSegment {
			selIdx = 0
		}
		
		let str = titleForSegment(at: selIdx) ?? ""
		
		return str
	}
}
