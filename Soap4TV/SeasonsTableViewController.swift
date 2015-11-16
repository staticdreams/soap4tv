//
//  SeasonsTableViewController.swift
//  Soap4TV
//
//  Created by Peter on 13/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {
	
	var seasons = [Season]() {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	var tvshowController: TVShowViewController?
	
	override func viewDidLoad() {}
	
	func currentSeason(season: Season) {
		tvshowController?.filterSeason(season.seasonNumber)
		if let cell = self.tableView.viewWithTag(season.seasonNumber) as? UITableViewCell {
			let indexPath = self.tableView.indexPathForCell(cell)
			self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let season = seasons[indexPath.row]
		currentSeason(season)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return seasons.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("seasonCell")!
		let season = seasons[indexPath.row]
		cell.tag = season.seasonNumber
		cell.textLabel?.text = "Сезон \(season.seasonNumber)"
		return cell
	}
	
	
}
