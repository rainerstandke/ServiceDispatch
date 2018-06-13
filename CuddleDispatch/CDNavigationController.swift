//
//  CDNavigationController.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/12/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit
import FirebaseAuth


class CDNavigationController: UINavigationController, UINavigationControllerDelegate {
	
	/* b/c an unwind segue is not triggered from navigation item (unless set up like a button with target & action, then trigger manually) we need to intercept popping back to sign-in controller here
	Could have done the same with a navCon delegate */
	override func popViewController(animated: Bool) -> UIViewController? {
		let popped = super.popViewController(animated: animated)
		
		if let popped = popped {
			if type(of: popped) == UIViewController.self { // TODO: replace with something else - possibly subclass
				let firebaseAuth = Auth.auth()
				do {
					try firebaseAuth.signOut()
				} catch let signOutError as NSError {
					print ("Error signing out: %@", signOutError)
				}
			}
		}
		
		return popped
	}
	
}
