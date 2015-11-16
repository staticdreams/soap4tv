//
//  EpisodeTableViewCell.swift
//  Soap4TV
//
//  Created by Peter on 13/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {

	@IBOutlet weak var episode: UILabel!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var quality: UILabel!
	@IBOutlet weak var translate: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
