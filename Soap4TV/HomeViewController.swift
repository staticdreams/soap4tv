//
//  HomeViewController.swift
//  Soap4TV
//
//  Created by Peter on 21/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyUserDefaults
import Cosmos

let featuredCellIdentifier = "featuredCell"

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var token: String?
	var featuredShows = [TVShow]()
	var allShows = [TVShow]()
	var scheduledEpisodes = [Schedule]()
	var selectedFeaturedShow: TVShow?
	var scheduleController: HomeScheduleCollectionView?
	var isImageBlurred = false
	
	let today = NSDate()
	let dateFormatter = NSDateFormatter()
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var topBanner: UIImageView!
	@IBOutlet weak var newShowsCollectionView: UICollectionView!
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var title_en: UILabel!
	@IBOutlet weak var title_ru: UILabel!
	@IBOutlet weak var text: FocusableText!
	@IBOutlet weak var watchLabel: UILabel!
	@IBOutlet weak var likeLabel: UILabel!
	@IBOutlet weak var rating: CosmosView!
	@IBOutlet weak var genres: UILabel!
	@IBOutlet weak var imdbScore: UILabel!
	@IBOutlet weak var kinopoiskScore: UILabel!
	@IBOutlet weak var newTitlesLabel: UILabel!
	@IBOutlet weak var watchButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var scheduleSwitch: UISegmentedControl!
	
    override func viewDidLoad() {
		super.viewDidLoad()
		setupScheduleSegments()
		self.newShowsCollectionView.registerNib(UINib(nibName: "FeaturedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: featuredCellIdentifier)
		topBanner.image = UIImage(named: "featured-background")
		loadFeaturedData({
			self.loadSchedule()
		})
	}
	
	func setupScheduleSegments() {
		let inTwoDays = Weekdays(rawValue: today.someDay(+2).dayOfTheWeek())
		let inThreeDays = Weekdays(rawValue: today.someDay(+3).dayOfTheWeek())
		scheduleSwitch.setTitle(inTwoDays?.day(), forSegmentAtIndex: 3)
		scheduleSwitch.setTitle(inThreeDays?.day(), forSegmentAtIndex: 4)
		let switchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 30.0)!]
		let selectedSwitchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 32.0)!]
		scheduleSwitch.setTitleTextAttributes(switchAttributes, forState: .Normal)
		scheduleSwitch.setTitleTextAttributes(selectedSwitchAttributes, forState: .Selected)
		scheduleSwitch.setTitleTextAttributes(selectedSwitchAttributes, forState: .Focused)
		scheduleSwitch.selectedSegmentIndex = 1 // Today index
	}
	
	@IBAction func scheduleChanged(sender: AnyObject) {
		switch(scheduleSwitch.selectedSegmentIndex) {
		case 0:
			filterSchedule(today.someDay(-1))
			break
		case 1:
			filterSchedule(today)
			break
		case 2:
			filterSchedule(today.someDay(+1))
			break
		case 3:
			filterSchedule(today.someDay(+2))
			break
		case 4:
			filterSchedule(today.someDay(+3))
			break
		default:
			filterSchedule(today)
		}
	}
	
	@IBAction func openShow(sender: AnyObject) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let show = storyboard.instantiateViewControllerWithIdentifier("showController") as! TVShowViewController
		if let object = self.selectedFeaturedShow {
			show.show = object
		}
		self.presentViewController(show, animated: true, completion: nil)
	}
	
	@IBAction func likeShow(sender: AnyObject) {
		
	}
	
	private func loadFeaturedData(callback: () -> ()) {
		guard let token = self.token else {
			print("Failed to get token")
			return
		}
		print("token is: \(token)")
		API().getTVShows(token, view: nil) { objects, error in
			if let shows = objects {
				self.allShows = shows
				let sortedShows = shows.sort(>)
				self.featuredShows = sortedShows.takeElements(Config.maxNumberFeatured)
				self.newShowsCollectionView.reloadData()
				delay(0.5) {
					let indexPath = NSIndexPath(forRow: 0, inSection: 0)
					self.newShowsCollectionView.delegate?.collectionView!(self.newShowsCollectionView, didSelectItemAtIndexPath: indexPath)
				}
				self.scheduleController?.setShows(self.allShows)
				callback()
			}
		}
	}
	
	func loadSchedule() {
		guard let token = self.token else {
			print("Failed to get token")
			return
		}
		API().getFullSchedule(token) { objects, error in
			if let schedule = objects {
				self.scheduledEpisodes = schedule
				self.filterSchedule(self.today)
			}
		}
	}
	
	func filterSchedule(filterDate: NSDate) {
		self.scheduleController?.loadSchedule(scheduledEpisodes.filter{($0.date?.sameDate(filterDate))!})
	}
	
	func showFeaturedUI(show: Bool) {
		
		if show == false {
			self.title_en.hidden = true
			self.title_ru.hidden = true
			self.text.hidden = true
			self.imdbScore.hidden = true
			self.kinopoiskScore.hidden = true
			self.rating.hidden = true
			self.watchLabel.hidden = true
			self.watchButton.hidden = true
			self.likeLabel.hidden = true
			self.likeButton.hidden = true
			self.newTitlesLabel.hidden = true
		} else {
			self.title_en.hidden = false
			self.title_ru.hidden = false
			self.text.hidden = false
			self.imdbScore.hidden = false
			self.kinopoiskScore.hidden = false
			self.rating.hidden = false
			self.watchLabel.hidden = false
			self.watchButton.hidden = false
			self.likeLabel.hidden = false
			self.likeButton.hidden = false
			self.newTitlesLabel.hidden = false
		}
	}
	
	func getFeaturedShowInfo(show: TVShow) {
		// TODO: Implement smooth fade in/out transition
		
		guard let tvdb = show.tvdb_id, tvdbtoken = Defaults[.TVDBToken] else { return }
		self.text.show = show
		self.text.parentView = self
		TVDB().getShow(tvdb, token: tvdbtoken) { showResponse, error in
			if let showItem = showResponse {
				
				TVDB().getImage(tvdb, token: tvdbtoken, type: "poster", resolution: nil, subKey: nil) { posterResponse, error in
					guard let posterResponse = posterResponse else {return}
					let object = posterResponse["data"].first
					if let poster = object {
						guard let url = NSURL(string: "\(Config.tvdb.baseURL)\(poster.1["fileName"])") else {
							return
						}
						if !self.isImageBlurred {
							let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
							let blurView = UIVisualEffectView(effect: blurEffect)
							blurView.frame = self.topBanner.bounds
							self.topBanner.addSubview(blurView)
						}
						
						self.showFeaturedUI(true)
						
						self.poster.af_setImageWithURL(url)
						self.title_en.text = show.title
						self.title_ru.text = show.title_ru
						self.text.text = show.description
						self.kinopoiskScore.text = show.kinopoisk_rating == 0.0 ? "" : "КиноПоиск "+String(show.kinopoisk_rating!)
						if let imdbRating = show.imdb_rating {
							if imdbRating > 0.0 {
								self.rating.rating = Double(imdbRating/2)
								self.imdbScore.text = "IMDB "+String(imdbRating)
							} else {
								self.rating.rating = 0
								self.imdbScore.text = ""
							}
						}
						self.genres.text = ""
						for genre in showItem["data"]["genre"] {
							let g = GenreType(rawValue: String(genre.1))
							if let gType = g {
								let string = self.genres.text?.stringByAppendingFormat("\n %@", "\(gType.translate())")
								self.genres.text = string
							}
						}
						
						self.selectedFeaturedShow = show
						self.isImageBlurred = true
					}
				}
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return featuredShows.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell:FeaturedCollectionViewCell?
		
		if cell == nil {
			cell = newShowsCollectionView.dequeueReusableCellWithReuseIdentifier(featuredCellIdentifier, forIndexPath: indexPath) as? FeaturedCollectionViewCell
		}

		let show = featuredShows[indexPath.row]
		if let sid = show.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg")!
			let placeholderImage = UIImage(named: "placeholder")!
			cell?.cover.af_setImageWithURL(URL, placeholderImage: placeholderImage)
		}
		return cell!
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//		if let cell = newShowsCollectionView.dequeueReusableCellWithReuseIdentifier(featuredCellIdentifier, forIndexPath: indexPath) as? FeaturedCollectionViewCell {
//			UIView.animateWithDuration(0.1, animations: {
//				cell.transform = CGAffineTransformMakeScale(2.5,2.5)
//			})
//		}
		let show = featuredShows[indexPath.row]
		getFeaturedShowInfo(show)

	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? FeaturedCollectionViewCell {
			next.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				self.scrollView.setContentOffset(CGPointZero, animated: true)
				}, completion: { done in
			})
		}
		
		if let prev = context.previouslyFocusedView as? FeaturedCollectionViewCell {
			prev.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.1, animations: {
				prev.transform = CGAffineTransformIdentity
			})
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "scheduleSegue" {
			if let controller = segue.destinationViewController as? HomeScheduleCollectionView {
				self.scheduleController = controller
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}
