//
//  AppDelegate.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/12/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	static var stationStrings = [String]() // classvar to be used in editing a request
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = true
		
		createStationList()
		
		return true
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		
	}
	func applicationDidEnterBackground(_ application: UIApplication) {
		
	}
	
	// Mark: -

	func createStationList() {
		let dbRef = Database.database().reference()
		
		dbRef.child("station-list").observeSingleEvent(of: .value) { (snapShot) in

			if snapShot.exists(),
				let stationListStr = snapShot.value as? String {
					let subStrings = stationListStr.split(separator: " ")
					type(of: self).stationStrings = subStrings.map { return String($0) }
				} else {
				let stationList = { () -> String in
					var result = ""
					for floor in 2...6 {
						for cardinalDirection in ["E", "W"] {
							for station in 1...6 {
								result.append(String(floor) + cardinalDirection + "-" + String(station) + " ")
							}
						}
					}
					return result
				}()
				
				dbRef.child("station-list").setValue(stationList)
			}
		}
	}
}

