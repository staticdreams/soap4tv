//
//  scheduleTableViewCell.swift
//  Soap4TV
//
//  Created by Peter on 20/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var seasonEpisode: UILabel!
	@IBOutlet weak var title: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
