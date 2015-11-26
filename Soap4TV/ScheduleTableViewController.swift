//
//  ScheduleTableViewController.swift
//  Soap4TV
//
//  Created by Peter on 20/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

let cellIdentifier = "scheduleCell"

class ScheduleTableViewController: UITableViewController {
	
	var data = [Schedule]()
	var sid: Int?
	var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.registerNib(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
		token = Defaults[.token]!
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loadData()
	}
	
	func loadData() {
		if let token = self.token, sid = self.sid {
			API().getSchedule(token, sid: sid) { objects, error in
				if let result = objects {
					self.data = result
					self.tableView.reloadData()
				}
			}
		}
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ScheduleTableViewCell
		let schedule = data[indexPath.row]
		cell.title.text = schedule.title
		cell.seasonEpisode.text = schedule.episode
//		cell.date.text = schedule.date
        return cell
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	

}
