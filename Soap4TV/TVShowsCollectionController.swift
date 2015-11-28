//
//  TVShowsCollectionController.swift
//  Soap4TV
//
//  Created by Peter on 28/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Kingfisher

private let reuseIdentifier = "showCell"

class TVShowsCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	var currentView = PresentedView()
	var allShows = [TVShow]()
	var data = [TVShow]() {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	
	let placeholderImage = UIImage(named: "placeholder")!
	
	@IBOutlet weak var sortingControl: UISegmentedControl!
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView.remembersLastFocusedIndexPath = true
		self.collectionView.registerNib(UINib(nibName: "TVShowCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		if data.count == 0 {loadData()}
    }
	
	@IBAction func sortingChanged(sender: AnyObject) {
		refresh(self.sortingControl.selectedSegmentIndex)
	}
	
	private func loadData() {
		print("Priliminary data load")
		guard let token = Defaults[.token] else {
			print("Failed to get token")
			return
		}
		print("token is: \(token)")
		API().getTVShows(token, view: currentView) { objects, error in
			if let tvshows = objects {
				self.allShows = tvshows
				self.refresh(0)
			}
		}
	}
	
	func refresh(sortOption: Int) {
		var shows = [TVShow]()
		print("Sort index changed to \(sortOption)")
		switch(sortOption) {
		case 0:
			shows = allShows.sort(>)
			break
		case 1:
			shows = allShows.sort(~)
			break
		case 2:
			shows = allShows.sort(±)
			break
		case 3:
			shows = allShows.sort(§)
			break
		default:
			break
		}
		self.data = shows
	}
	
	// MARK: - Collection View Delegate and DataSource
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return data.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TVShowCell
		let tvshow = data[indexPath.row]
		cell.show = tvshow
		if cell.gestureRecognizers?.count == nil {
			let tap = UITapGestureRecognizer(target: self, action: "tapped:")
			tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
			cell.addGestureRecognizer(tap)
		}
		if let sid = tvshow.sid {
			if let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg") {
				cell.cover.kf_setImageWithURL(URL, placeholderImage: placeholderImage)
			}
		}
		
		cell.alpha = 0
		UIView.animateWithDuration(0.5, animations: { cell.alpha = 1 })
		return cell
	}
	
	func tapped(gesture: UITapGestureRecognizer) {
		if let cell = gesture.view as? TVShowCell {
			let show = self.storyboard?.instantiateViewControllerWithIdentifier("tvshowController") as! TVShowViewController
			show.show = cell.show
			self.presentViewController(show, animated: true, completion: nil)
		}
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? TVShowCell {
			next.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				}, completion: { done in
			})
		}
		
		if let prev = context.previouslyFocusedView as? TVShowCell {
			prev.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.1, animations: {
				prev.transform = CGAffineTransformIdentity
			})
		}
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
