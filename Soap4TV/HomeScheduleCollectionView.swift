//
//  HomeScheduleCollectionView.swift
//  Soap4TV
//
//  Created by Peter on 26/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage

private let reuseIdentifier = "scheduleCollectionCell"

class HomeScheduleCollectionView: UICollectionViewController {
	
	var shows = [TVShow]()
	var data = [Schedule]()
	let dateFormatter = NSDateFormatter()
	let placeholderImage = UIImage(named: "placeholder")!
	
	override func viewDidLoad() {
		self.collectionView!.registerNib(UINib(nibName: "ScheduleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
	}
	
	func loadSchedule(schedule: [Schedule]) {
		self.data = schedule
		collectionView?.reloadData()
	}
	
	func setShows(shows: [TVShow]) {
		self.shows = shows
	}
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return data.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ScheduleCollectionViewCell
		
		let schedule = data[indexPath.row]
		let show = shows.filter{$0.sid == schedule.sid}
		cell.showTitle.text = show.first?.title // <-- top one
		cell.episodeTitle.text = schedule.title
		cell.showEpisode.text = schedule.episode
		if let sid = schedule.sid {
			if let URL = NSURL(string: "\(Config.URL.covers)/soap/\(sid).jpg") {
				cell.cover.af_setImageWithURL(URL, placeholderImage: placeholderImage)
			}
		}
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let schedule = data[indexPath.row]
		let items = shows.filter{$0.sid == schedule.sid}
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let show = storyboard.instantiateViewControllerWithIdentifier("showController") as? TVShowViewController {
			if let item = items.first {
				show.show = item
				self.presentViewController(show, animated: true, completion: nil)
			}
		}
		
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? ScheduleCollectionViewCell {
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.layer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1).CGColor
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				}, completion: { done in
			})
		}
		
		if let prev = context.previouslyFocusedView as? ScheduleCollectionViewCell {
			UIView.animateWithDuration(0.1, animations: {
				prev.layer.backgroundColor = UIColor.clearColor().CGColor
				prev.transform = CGAffineTransformIdentity
			})
		}
	}

}
