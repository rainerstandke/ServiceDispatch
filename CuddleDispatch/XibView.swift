//
//  XibView.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/20/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//

import UIKit


@IBDesignable
class XibView : UIView {
	
	var contentView:UIView?
	@IBInspectable var nibName:String?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		xibSetup()
	}
	
	func xibSetup() {
		guard let view = loadViewFromNib() else { return }
		view.frame = bounds
		view.autoresizingMask =
			[.flexibleWidth, .flexibleHeight]
		addSubview(view)
		contentView = view
	}
	
	func loadViewFromNib() -> UIView? {
		guard let nibName = nibName else { return nil }
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: nibName, bundle: bundle)
		return nib.instantiate(
			withOwner: self,
			options: nil).first as? UIView
	}

	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		xibSetup()
		contentView?.prepareForInterfaceBuilder()
	}
}
