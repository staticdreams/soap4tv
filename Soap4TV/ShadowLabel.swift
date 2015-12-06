//
//  ShadowLabel.swift
//  Soap4TV
//
//  Created by Peter on 06/12/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class ShadowLabel: UILabel {

	override func awakeFromNib() {
		self.layer.shadowColor = UIColor.blackColor().CGColor
		self.layer.shadowOffset = CGSizeMake(0, 2)
		self.layer.shadowOpacity = 0.4
		self.layer.shadowRadius = 8
	}

}
