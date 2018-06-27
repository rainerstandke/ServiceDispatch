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

//	func applicationWillEnterForeground(_ application: UIApplication) {
//		print("applicationWillEnterForeground")
//	}
//	func applicationDidEnterBackground(_ application: UIApplication) {
//		print("applicationDidEnterBackground")
//	}
//	func applicationDidBecomeActive(_ application: UIApplication) {
//		print("applicationDidBecomeActive")
//	}
//	func applicationWillResignActive(_ application: UIApplication) {
//		print("applicationWillResignActive")
//	}
//	func applicationWillTerminate(_ application: UIApplication) {
//		print("applicationWillTerminate")
//	}
	
	// Mark: -

	func createStationList() {
		
		let dbRef = Database.database().reference()
		
		func useLocallyGeneratedStationStrings() {
			let localStrs = { () -> [String] in
				var strs = [String]()
				for floor in 2...6 {
					for cardinalDirection in ["E", "W"] {
						for station in 1...6 {
							strs.append(String(floor) + cardinalDirection + "-" + String(station))
						}
					}
				}
				return strs
			}()
			type(of: self).stationStrings = localStrs
			dbRef.child("station-list").setValue(localStrs.joined(separator: " "))
		}
		
		if Auth.auth().currentUser != nil {
			dbRef.child("station-list").observeSingleEvent(of: .value) { (snapShot) in
				
				if snapShot.exists(),
					let stationListStr = snapShot.value as? String {
					let subStrings = stationListStr.split(separator: " ")
					type(of: self).stationStrings = subStrings.map { return String($0) }
				} else {
					useLocallyGeneratedStationStrings()
				}
			}
		} else {
			// user not logged in
			useLocallyGeneratedStationStrings()
		}
	}
}

