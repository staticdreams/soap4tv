//
//  TVShowCollectionController.swift
//  Soap4TV
//
//  Created by Peter on 11/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Kingfisher

private let reuseIdentifier = "showCell"

class ___TVShowCollectionController: UICollectionViewController, UISearchResultsUpdating {
	
	var allShows = [TVShow]()
	
	var data = [TVShow]() {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	var currentView = PresentedView()
	var userLikes = [Int]()
	
	let placeholderImage = UIImage(named: "placeholder")!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
		self.collectionView!.remembersLastFocusedIndexPath = true
		self.collectionView!.registerNib(UINib(nibName: "TVShowCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		if data.count == 0 {loadData()}
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
				self.refresh(tvshows)
			}
		}
	}
	
	func refresh(shows: [TVShow]) {
		print("Refreshing data")
		if self.currentView == .FavShows {
			self.data = shows.filter {self.userLikes.contains($0.sid)}
			if self.data.count == 0 {
				print("No shows in favorites")
			}
		} else {
			self.data = shows
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		userLikes = Defaults.hasKey(.like) ? Defaults[.like]! : []
		 
		// FIXME: Temporary solution for refreshing favs view. which is ugly
		let filteredData = allShows.filter {self.userLikes.contains($0.sid)}
		if data != filteredData && self.currentView == .FavShows {
			refresh(allShows)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TVShowCell
		let tvshow = data[indexPath.row]
		cell.show = tvshow
//		cell.title.text = tvshow.title
//		cell.titleRu.text = tvshow.title_ru
//		if let imdb_rating = tvshow.imdb_rating {
//			cell.imdb.text = "IMDB: \(String(imdb_rating))"
//		} else {}
//		if let kp_rating = tvshow.kinopoisk_rating where kp_rating != 0.0 {
//			cell.kinopoisk.text = "Кинопоиск: \(String(kp_rating))"
//		} else {}
//		cell.year.text = "(\(String(tvshow.year!)))"
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
			/**
			*   Makes cell bigger
			*/
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				}, completion: { done in
			})
			
			/**
			*   Animates white box
			*/
//			next.overlayHeightConstraint.constant = 300
//			UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 2, options: [], animations: {
//				self.view.layoutIfNeeded()
//				}) { completed in
//			}
			/**
			*	Animating text within the white box after it appears
			*/
//			UIView.animateWithDuration(0.3, delay: 0.5, options: [.TransitionCrossDissolve], animations: { () -> Void in
//				next.titleRu.alpha = 1
//				next.year.alpha = 1
//				next.imdb.alpha = 1
//				next.kinopoisk.alpha = 1
//				}, completion: nil)
		}
		
		if let prev = context.previouslyFocusedView as? TVShowCell {
			
			/**
			*   Makes cell smaller
			*/
			prev.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.1, animations: {
				prev.transform = CGAffineTransformIdentity
//				prev.titleRu.alpha = 0
//				prev.year.alpha = 0
//				prev.imdb.alpha = 0
//				prev.kinopoisk.alpha = 0
			})
			
			/**
			*   Animates white box
			*/
//			prev.overlayHeightConstraint.constant = 90
//			UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 2, options: [], animations: {
//				self.view.layoutIfNeeded()
//				}) { completed in
//			}
			
			/**
			*	Hiding text within the white box after it disappears
			*/
//			UIView.animateWithDuration(0.3, delay: 0.0, options: [.TransitionCrossDissolve], animations: { () -> Void in
//				
//			}, completion: nil)
		}
		
	}
	
	// MARK: UISearchResultsUpdating
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
//		filterString = searchController.searchBar.text ?? ""
	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
