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
	var selectedFeaturedShow: TVShow?
	
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
	
	var isImageBlurred = false
	
    override func viewDidLoad() {
		super.viewDidLoad()
		text.selectable = true
		self.newShowsCollectionView.registerNib(UINib(nibName: "FeaturedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: featuredCellIdentifier)
		topBanner.image = UIImage(named: "featured-background")
		//	topBanner.kf_setImageWithURL(NSURL(string: "http://thetvdb.com/banners/fanart/original/298156-1.jpg")!)
		
		loadFeaturedData()
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
	
	func getFeaturedShowInfo(show: TVShow) {
		guard let tvdb = show.tvdb_id, token = Defaults[.TVDBToken] else {
			return
		}
		
		self.text.show = show
		self.text.parentView = self
		self.genres.text = ""
		TVDB().getShow(tvdb, token: token) { response, error in
			if let item = response {
				for genre in item["data"]["genre"] {
					let g = GenreType(rawValue: String(genre.1))
					if let gType = g {
						let string = self.genres.text?.stringByAppendingFormat("\n %@", "\(gType.translate())")
						self.genres.text = string
					}
				}
				
				TVDB().getPoster(tvdb, token: token) { response, error in
					guard let response = response else {return}
					let object = response["data"].first
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
		let show = featuredShows[indexPath.row]
		getFeaturedShowInfo(show)
		scrollView.setContentOffset(CGPointZero, animated: true)
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? FeaturedCollectionViewCell {
			next.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				}, completion: nil)
		}
		
		if let prev = context.previouslyFocusedView as? FeaturedCollectionViewCell {
			prev.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.1, animations: {
				prev.transform = CGAffineTransformIdentity
			})
		}
	}
	
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/*
	
	1. Get 20 latest tv shows
	2. Get /my tv shows schedule
	3. Get popular tv shows

	
	*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
