//
//  StatusView.swift
//  CuddleDispatch
//
//  Created by Rainer Standke on 6/20/18.
//  Copyright © 2018 Rainer Standke. All rights reserved.
//




/*  https://medium.com/zenchef-tech-and-product/how-to-visualize-reusable-xibs-in-storyboards-using-ibdesignable-c0488c7f525d  */
import UIKit

@IBDesignable class StatusView: UIView {

	var contentView:UIView?
//	@IBInspectable var nibName:String?
	let nibName = "StatusView"
	
	@IBOutlet var leftImgVu: UIImageView!
	@IBOutlet var rightImgVu: UIImageView!
	
	public var status = CuddleStatus.none {
		didSet(oldValue) {
			changeStatusDisplay(from: oldValue)
			statusChangeCallBack?(status)
		}
	}
	
	public var statusChangeCallBack: ((_ status: CuddleStatus) -> ())? = nil
	
	
	@IBAction func leftImgTapped(sender: UITapGestureRecognizer) {
		if status == .none || status == .concluded {
			status = .inProgress
		}
	}
	
	@IBAction func rightImgTapped(sender: UITapGestureRecognizer) {
		if status == .inProgress {
			status = .concluded
		}
	}
	
//	override func awakeFromNib() {
//		super.awakeFromNib()
////		xibSetup()
//		status = .none
//	}
	
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		xibSetup()
//		status = .none
//
//	}
//
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		guard let view = loadViewFromNib() else { return }
		view.frame = self.bounds
		self.addSubview(view)
		contentView = view
		
		
//		xibSetup()
		status = .none
	}

//	func xibSetup() {
//		guard let view = loadViewFromNib() else { return }
//		view.frame = bounds
//		view.autoresizingMask =
//			[.flexibleWidth, .flexibleHeight]
//		addSubview(view)
////		contentView = view
////		self.view.addSubview(view)
//	}
	
	func loadViewFromNib() -> UIView? {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: nibName, bundle: bundle)
		return nib.instantiate(
			withOwner: self,
			options: nil).first as? UIView
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
//		xibSetup()
		contentView?.prepareForInterfaceBuilder()
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
			leftImgVu.tintAdjustmentMode = .normal
			leftImgVu.tintColor = self.tintColor
			if from == .none {
				rightImgVu.image = nil
			} else {
				rightImgVu.image = UIImage.init(named: "Done.pdf")
				rightImgVu.tintColor = UIColor.black
			}
		case .inProgress:
			rightImgVu.image = UIImage.init(named: "Out.pdf")
			rightImgVu.tintColor = self.tintColor
			leftImgVu.tintAdjustmentMode = .dimmed
		case .concluded:
			leftImgVu.tintAdjustmentMode = .normal
			rightImgVu.tintColor = UIColor.black
			rightImgVu.image = UIImage.init(named: "Done.pdf")
		}
	}
}


//enum CuddleStatus: String {
//	case none // original, before first cuddle
//	case inProgress
//	case concluded // after first cuddle conclusion
//}
