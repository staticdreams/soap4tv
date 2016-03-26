//
//  TVShowsCollectionController.swift
//  Soap4TV
//
//  Created by Peter on 28/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

private let reuseIdentifier = "showCell"

enum TVShowSection: Int {
	case unwatched = 0, watched, finished
}

class TVShowsCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	
	var currentView = PresentedView()
	var allShows = [TVShow]()
	var unwatchedShows = [TVShow]()
	var watchedShows = [TVShow]()
	var finishedShows = [TVShow]()
	
	var data = [TVShow]() {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	var isLoading: Bool = false
	var useUnwatchedSort: Bool = false
	var sorting = 0
	
	var api = API()
	
	let placeholderImage = UIImage(named: "placeholder")!
	
	@IBOutlet weak var sortingControl: UISegmentedControl!
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let switchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 30.0)!]
		let selectedSwitchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 32.0)!]
		sortingControl.setTitleTextAttributes(switchAttributes, forState: .Normal)
		sortingControl.setTitleTextAttributes(selectedSwitchAttributes, forState: .Selected)
		sortingControl.setTitleTextAttributes(selectedSwitchAttributes, forState: .Focused)
		self.collectionView.remembersLastFocusedIndexPath = true
		self.collectionView.registerNib(UINib(nibName: "TVShowCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		
		self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
		let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		flow.headerReferenceSize = CGSizeMake(40,30)
		
		self.useUnwatchedSort = (self.sortingControl.numberOfSegments > 4)

		if data.count == 0 {loadData()}
    }
	
	override func viewWillAppear(animated: Bool) {
		if isLoading == false { self.loadData() }
		super.viewWillAppear(animated)
	}
	
	@IBAction func sortingChanged(sender: AnyObject) {
		refresh(self.sortingControl.selectedSegmentIndex)
	}
	
	private func loadData() {
		isLoading = true;
		print("Priliminary data load")
		guard let token = Defaults[.token] else {
			print("Failed to get token")
			isLoading = false
			return
		}
		print("token is: \(token)")
		api.getTVShows(token, view: currentView) { objects, error in
			if let tvshows = objects {
				self.allShows = tvshows
				self.refresh(self.sorting)
			}
			self.isLoading = false
		}
	}
	
	func refresh(sortOption: Int) {
		var shows = [TVShow]()
		print("Sort index changed to \(sortOption)")
		self.sorting = sortOption
		
		if (self.useUnwatchedSort == true) {
			DLog("1")
			switch(sortOption) {
				case 0:
					self.unwatchedShows = allShows.filter {$0.unwatched > 0}
					self.watchedShows = allShows.filter { $0.unwatched == nil && $0.status == 0 }
					self.finishedShows = allShows.filter { $0.unwatched == nil && $0.status != 0 }
					
					self.unwatchedShows = self.unwatchedShows.sort(•)
					self.watchedShows = self.watchedShows.sort(•)
					self.finishedShows = self.finishedShows.sort(•)
					
					shows = allShows.sort(•)
					break
				case 1:
					shows = allShows.sort(>)
					break
				case 2:
					shows = allShows.sort(~)
					break
				case 3:
					shows = allShows.sort(±)
					break
				case 4:
					shows = allShows.sort(§)
					break
				default:
					break
			}
		} else {
			DLog("2")
			DLog(sortOption)
			switch(sortOption) {
			case 0:
				shows = allShows.sort(>)
				DLog(shows.count)
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
		}
		self.data = shows
		collectionView.setContentOffset(CGPointZero, animated: false) // this isn't enough. needs to select first cell
	}
	
	// MARK: - Collection View Delegate and DataSource
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		let numberOfSections = (self.sorting == 0 && self.useUnwatchedSort) ? 3 : 1
		return numberOfSections
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numberOfItems = data.count
		
		if (self.sorting == 0 && self.useUnwatchedSort) {
			switch section {
				case TVShowSection.unwatched.rawValue:
					numberOfItems = self.unwatchedShows.count
					break
				case TVShowSection.watched.rawValue:
					numberOfItems = self.watchedShows.count
					break
				case TVShowSection.finished.rawValue:
					numberOfItems = self.finishedShows.count
					break
				default:
					break
			}
		}
		
		return numberOfItems
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TVShowCell
		
		var tvshow = data[indexPath.row]
		
		if (self.sorting == 0 && self.useUnwatchedSort) {
			switch indexPath.section {
				case TVShowSection.unwatched.rawValue:
					tvshow = self.unwatchedShows[indexPath.row]
					break
				case TVShowSection.watched.rawValue:
					tvshow = self.watchedShows[indexPath.row]
					break
				case TVShowSection.finished.rawValue:
					tvshow = self.finishedShows[indexPath.row]
					break
				default:
					break
			}
		}
		
		cell.show = tvshow
		if cell.gestureRecognizers?.count == nil {
			let tap = UITapGestureRecognizer(target: self, action: #selector(TVShowsCollectionController.tapped(_:)))
			tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
			cell.addGestureRecognizer(tap)
		}
		if let sid = tvshow.sid {
			if let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg") {
				cell.cover.af_setImageWithURL(URL, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
			}
		}
		cell.title_en.text = tvshow.title
		cell.title_ru.text = tvshow.title_ru
		if let year = tvshow.year, let imdb = tvshow.imdb_rating {
			cell.year.text = "(\(year))"
			cell.imdb.text = "IMDB \(imdb)"
		}
		
		if let unwatched = tvshow.unwatched {
			cell.unwatchedLabel.text = String(unwatched)
			cell.badge.hidden = false
		} else {
			cell.badge.hidden = true
		}
		
		cell.overlay.alpha = 0
		cell.alpha = 0
		
		UIView.animateWithDuration(0.5, animations: { cell.alpha = 1 })
		return cell
	}
	
	func tapped(gesture: UITapGestureRecognizer) {
		if let cell = gesture.view as? TVShowCell {
			let show = self.storyboard?.instantiateViewControllerWithIdentifier("showController") as! TVShowViewController
			show.show = cell.show
			self.presentViewController(show, animated: true, completion: nil)
		}
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? TVShowCell {
			next.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				next.overlay.alpha = 0.8
//				if self.currentView == .MyShows {
					next.badge.hidden = true
//				}
				}, completion: { done in
			})
		}
		
		if let prev = context.previouslyFocusedView as? TVShowCell {
			prev.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.1, animations: {
				prev.transform = CGAffineTransformIdentity
				prev.overlay.alpha = 0
				if prev.unwatchedLabel.text != "" {
					prev.badge.hidden = false
				}
			})
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
