//
//  FeaturedCollectionViewCell.swift
//  Soap4TV
//
//  Created by Peter on 22/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class FeaturedCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var cover: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOffset = CGSizeMake(0, 2)
		layer.shadowOpacity = 0.4
		layer.shadowRadius = 8
	}
	
}
