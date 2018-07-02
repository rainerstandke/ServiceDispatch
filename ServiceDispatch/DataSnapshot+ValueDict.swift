//
//  DataSnapshot+ValueDict.swift
//  ServiceDispatch
//
//  Created by Rainer Standke on 6/18/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import Foundation
import Firebase

extension DataSnapshot {
	
	func valueDict() -> [String: Any] {
		return self.value as? [String:String] ?? [:]
	}
}
