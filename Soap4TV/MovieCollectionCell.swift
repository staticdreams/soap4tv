//
//  MovieCollectionCell.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
	
	var show: TVShow?
	
	@IBOutlet weak var cover: UIImageView!
	@IBOutlet weak var overlay: UIView!
	@IBOutlet weak var overlayHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var titleRu: UILabel!
	@IBOutlet weak var year: UILabel!
	@IBOutlet weak var imdb: UILabel!
	@IBOutlet weak var kinopoisk: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		titleRu.alpha = 0
		year.alpha = 0
		imdb.alpha = 0
		kinopoisk.alpha = 0
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let shadowPath = UIBezierPath.init(rect: self.bounds)
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.blackColor().CGColor
		self.layer.shadowOffset = CGSizeMake(0, 4)
		self.layer.shadowOpacity = 0.35
		self.layer.shadowPath = shadowPath.CGPath
	}
	
}