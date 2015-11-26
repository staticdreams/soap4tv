//
//  HomeScheduleCollectionView.swift
//  Soap4TV
//
//  Created by Peter on 26/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "scheduleCollectionCell"

class HomeScheduleCollectionView: UICollectionViewController {
	
	var data = [Schedule]()
	
	override func viewDidLoad() {
		self.collectionView!.registerNib(UINib(nibName: "ScheduleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
	}
	
	func loadSchedule(schedule: [Schedule]) {
		self.data = schedule
		collectionView?.reloadData()
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
		
		cell.showTitle.text = schedule.title
		cell.showEpisode.text = schedule.episode
		if let sid = schedule.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/\(sid).jpg")!
			let placeholderImage = UIImage(named: "placeholder")!
			cell.cover.kf_setImageWithURL(URL, placeholderImage: placeholderImage)
		}
		
		return cell
	}

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
