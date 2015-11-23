//
//  MovieDescriptionViewController.swift
//  Soap4TV
//
//  Created by Peter on 23/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class MovieDescriptionViewController: UIViewController {
	
	var descriptionText = ""
	
	@IBOutlet weak var textLabel: UILabel!
	
	override func viewDidLoad() {
		textLabel.text = descriptionText
	}
	
}
