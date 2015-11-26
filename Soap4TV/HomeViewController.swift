//
//  HomeViewController.swift
//  Soap4TV
//
//  Created by Peter on 21/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyUserDefaults
import Cosmos

let featuredCellIdentifier = "featuredCell"

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var token: String?
	var featuredShows = [TVShow]()
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
		text.selectable = true
		self.newShowsCollectionView.registerNib(UINib(nibName: "FeaturedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: featuredCellIdentifier)
		topBanner.image = UIImage(named: "featured-background")
		let switchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 30.0)!]
		let selectedSwitchAttributes: [NSObject: AnyObject]? = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 32.0)!]
		scheduleSwitch.setTitleTextAttributes(switchAttributes, forState: .Normal)
		scheduleSwitch.setTitleTextAttributes(selectedSwitchAttributes, forState: .Selected)
		scheduleSwitch.setTitleTextAttributes(selectedSwitchAttributes, forState: .Focused)
		scheduleSwitch.selectedSegmentIndex = 1 // Today index
		loadFeaturedData()
		loadSchedule()
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
		let show = self.storyboard?.instantiateViewControllerWithIdentifier("tvshowController") as! TVShowViewController
		if let object = self.selectedFeaturedShow {
			show.show = object
		}
		self.presentViewController(show, animated: true, completion: nil)
	}
	
	@IBAction func likeShow(sender: AnyObject) {
		
	}
	
	private func loadFeaturedData() {
		guard let token = self.token else {
			print("Failed to get token")
			return
		}
		print("token is: \(token)")
		API().getTVShows(token, view: nil) { objects, error in
			if let shows = objects {
				let sortedShows = shows.sort(>)
				self.featuredShows = sortedShows.takeElements(Config.maxNumberFeatured)
				self.newShowsCollectionView.reloadData()
				delay(2.0) {
					let indexPath = NSIndexPath(forRow: 0, inSection: 0)
					self.newShowsCollectionView.delegate?.collectionView!(self.newShowsCollectionView, didSelectItemAtIndexPath: indexPath)
				}
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
	
	func getFeaturedShowInfo(show: TVShow) {
		guard let tvdb = show.tvdb_id, token = Defaults[.TVDBToken] else {
			return
		}
		
		self.text.show = show
		self.text.parentView = self
		
		TVDB().getShow(tvdb, token: token) { showResponse, error in
			if let showItem = showResponse {
				
				TVDB().getPoster(tvdb, token: token) { posterResponse, error in
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
						
						self.poster.kf_setImageWithURL(url)
						self.title_en.text = show.title
						self.title_ru.text = show.title_ru
						self.text.text = show.description
						self.imdbScore.text = "IMDB "+String(show.imdb_rating!)
						self.kinopoiskScore.text = show.kinopoisk_rating == 0.0 ? "" : "КиноПоиск "+String(show.kinopoisk_rating!)
						if let imdbRating = show.imdb_rating {
							self.rating.rating = Double(imdbRating/2)
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
		let cell = newShowsCollectionView.dequeueReusableCellWithReuseIdentifier(featuredCellIdentifier, forIndexPath: indexPath) as! FeaturedCollectionViewCell
		let show = featuredShows[indexPath.row]
		print(show.tvdb_id)
		if let sid = show.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg")!
			let placeholderImage = UIImage(named: "placeholder")!
			cell.cover.kf_setImageWithURL(URL, placeholderImage: placeholderImage)
		}
		return cell
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
				print("Houston we have a link")
				self.scheduleController = controller
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}
