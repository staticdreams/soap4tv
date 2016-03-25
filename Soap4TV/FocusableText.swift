//
//  FocusableLabel.swift
//  Soap4TV
//
//  Created by Peter on 23/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class FocusableText: UITextView {
	
	var show: TVShow?
	var parentView: UIViewController?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectable = true
		let tap = UITapGestureRecognizer(target: self, action: #selector(FocusableText.tapped(_:)))
		tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
		self.addGestureRecognizer(tap)
//		self.textContainerInset = UIEdgeInsetsZero
		self.layer.shadowColor = UIColor.blackColor().CGColor
		self.layer.shadowOffset = CGSizeMake(0, 2)
		self.layer.shadowOpacity = 0.4
		self.layer.shadowRadius = 8
	}
	
	func tapped(gesture: UITapGestureRecognizer) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let descriptionView = storyboard.instantiateViewControllerWithIdentifier("descriptionView") as? MovieDescriptionViewController {
			if let view = parentView {
				if let show = show {
					descriptionView.descriptionText = show.description!
					view.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
					view.presentViewController(descriptionView, animated: true, completion: nil)
				}
			}
		}
	}
	
	override func canBecomeFocused() -> Bool {
		return true
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if context.nextFocusedView == self {
			coordinator.addCoordinatedAnimations({ () -> Void in
				self.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
			}, completion: nil)
		} else if context.previouslyFocusedView == self {
			coordinator.addCoordinatedAnimations({ () -> Void in
				self.layer.backgroundColor = UIColor.clearColor().CGColor
			}, completion: nil)
		}
	}
	
}
