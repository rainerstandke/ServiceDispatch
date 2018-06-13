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


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		FirebaseApp.configure()
		
		createStationList()
		
		return true
	}

	func createStationList() {
		let dbRef = Database.database().reference()
		
		
		dbRef.child("station-list").observeSingleEvent(of: .value) { (snapShot) in

			if !snapShot.exists() {
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
			} else {
				print("station-list does exist")
			}
		}
	}

}

