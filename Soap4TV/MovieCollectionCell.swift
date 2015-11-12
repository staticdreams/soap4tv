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
}