//
//  FeaturedCollectionViewCell.swift
//  Soap4TV
//
//  Created by Peter on 22/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class TVShowCell: UICollectionViewCell {
	
	var show: TVShow?
    
	@IBOutlet weak var overlay: UIView!
	@IBOutlet weak var cover: UIImageView!
	@IBOutlet weak var title_en: UILabel!
	@IBOutlet weak var title_ru: UILabel!
	@IBOutlet weak var year: UILabel!
	@IBOutlet weak var imdb: UILabel!
	
	@IBOutlet weak var badge: UIView!
	@IBOutlet weak var unwatchedLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOffset = CGSizeMake(0, 2)
		layer.shadowOpacity = 0.4
		layer.shadowRadius = 8
//		self.badge.sizeToFit()
		self.badge.layer.cornerRadius = self.badge.frame.size.width / 2
	}
	
}
