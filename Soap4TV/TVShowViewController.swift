//
//  TVShowViewController.swift
//  Soap4TV
//
//  Created by Peter on 12/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import AVFoundation
import AVKit
import Cosmos

private let reuseIdentifier = "EpisodeCell"

enum Quality: String {
	case HD = "720p"
	case SD = "SD"
	init() {
		self = .HD
	}
}

enum Translation: String {
	case Translator
	case Subtitles = " Субтитры"
	init() {
		self = .Translator
	}
}

enum ButtonState: String {
	case Like = "like"
	case Dislike = "unlike"
	case Subtitle = "speech-bubble"
	case Translation = "talk"
	func image() -> UIImage {
		return UIImage(named: self.rawValue)!
	}
}

struct Season {
	let seasonNumber: Int
	let seasonId: Int
	init(number: Int, id: Int) {
		self.seasonNumber = number
		self.seasonId = id
	}
}

extension Season: Equatable {}

func ==(lhs: Season, rhs: Season) -> Bool {
	return lhs.seasonNumber == rhs.seasonNumber && lhs.seasonId == rhs.seasonId
}


class TVShowViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	var show: TVShow?
	var episodes = [Episode]()
	var allEpisodes = [Episode]()
	var token = ""
	var seasons = [Season]()
	var TVDBEpisodes = [TVDBEpisode]()
	
	var currentTranslation: String?
	var qualityView: UIView!
	var playerController: AVPlayerViewController?
	var userLikes = [Int]()
	var seasonsSegment: UISegmentedControl!
	var posterURL: NSURL?
	
	@IBOutlet weak var backgroundImage: UIImageView!
	@IBOutlet weak var poster: UIImageView!
	
	@IBOutlet weak var translationButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var translationLabel: UILabel!
	@IBOutlet weak var likeLabel: UILabel!

	@IBOutlet weak var showtitle: ShadowLabel!
	@IBOutlet weak var showtitle_ru: ShadowLabel!
	@IBOutlet weak var year: ShadowLabel!
	@IBOutlet weak var imdbRating: ShadowLabel!
	@IBOutlet weak var kinopoiskRating: ShadowLabel!
	@IBOutlet weak var rating: CosmosView!
	@IBOutlet weak var introduction: FocusableText!
	@IBOutlet weak var episodesCollection: UICollectionView!
	@IBOutlet weak var seasonsScroll: UIScrollView!
	
	@IBOutlet weak var genre: ShadowLabel!
	
	// MARK: - Preparation
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.episodesCollection.registerNib(UINib(nibName: "EpisodeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		setup()
		loadEpisodes()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		let likeImage = show?.watching == true ? ButtonState.Dislike.image() :  ButtonState.Like.image()
		likeLabel.text = show?.watching == true ? "Удалить из моих сериалов": "Добавить в мои сериалы"
		likeButton.setImage(likeImage, forState: UIControlState.Normal)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let translationImage = Defaults[.subtitles]! ? ButtonState.Subtitle.image() :  ButtonState.Translation.image()
		translationLabel.text = Defaults[.subtitles]! ? "Субтитры": "Перевод"
		translationButton.setImage(translationImage, forState: UIControlState.Normal)
	}

	@IBAction func likeTapped(sender: AnyObject) {
		
		guard let showWatching = show?.watching, showId = show?.sid else {
			return
		}
		show?.watching = !showWatching
		API().toggleWatch(token, show: String(showId), status: !showWatching) { response, error in
			print(response)
		}
		likeLabel.text = show?.watching == true ? "Удалить из моих сериалов": "Добавить в мои сериалы"
		let image = show?.watching == true ? ButtonState.Dislike.image() :  ButtonState.Like.image()
		likeButton.setImage(image, forState: UIControlState.Normal)
	}

	@IBAction func translationTapped(sender: AnyObject) {
		if let state = Defaults[.subtitles] {
			Defaults[.subtitles] = !state
			translationLabel.text = Defaults[.subtitles]! ? "Субтитры": "Перевод"
			let image = Defaults[.subtitles]! ? ButtonState.Subtitle.image() :  ButtonState.Translation.image()
			translationButton.setImage(image, forState: UIControlState.Normal)
			self.episodesCollection.reloadData()
		}
	}
	
	override var preferredFocusedView: UIView? {
		return self.seasonsSegment
	}
	
	func setup() {
		currentTranslation = Defaults.hasKey(.translation) ? Defaults[.translation] : Translation().rawValue
		token = Defaults[.token]!
		Defaults[.quality] = Defaults.hasKey(.quality) ? Defaults[.quality] : Quality.HD.rawValue
		Defaults[.subtitles] = Defaults.hasKey(.subtitles) ? Defaults[.subtitles] : false
		
		showtitle.text = show?.title!.decodeEntity()
		showtitle_ru.text = show?.title_ru!.decodeEntity()
		
		if let release = show?.year {
			self.year.text = String(release)+" год"
		}
		
		if let imdbRating = show?.imdb_rating {
			self.rating.rating = Double(imdbRating/2)
			if imdbRating > 0.0 {
				self.imdbRating.text = "IMDB "+String(imdbRating)
			}
		}
		
		if let kinopoisk = show?.kinopoisk_rating {
			if kinopoisk > 0.0 {
				self.kinopoiskRating.text = "КиноПоиск "+String(kinopoisk)
			}
		}
		
		self.introduction.show = show
		self.introduction.parentView = self
		self.introduction.text = show?.description!.decodeEntity()
		
		poster.layer.shadowColor = UIColor.blackColor().CGColor
		poster.layer.shadowOffset = CGSizeMake(0, 2)
		poster.layer.shadowOpacity = 0.4
		poster.layer.shadowRadius = 8

	}
	
	// MARK: - Loading and filtering data
	
	/**
	Load all the episodes for current TV show and construct a list of Seasons
	*/
	func loadEpisodes() {
		
		guard let showId = show?.sid else {return}
		getEpisodes(token, show: showId) {
			
			//MARK:  Setup segemented control
			
			let segments = self.seasons.map {String($0.seasonNumber)}
			self.seasonsSegment = UISegmentedControl(items: segments)
			self.seasonsSegment.apportionsSegmentWidthsByContent = true
			
			let switchAttributes: [NSObject: AnyObject]? = [NSForegroundColorAttributeName: UIColor.lightGrayColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 30.0)!]
			self.seasonsSegment.setTitleTextAttributes(switchAttributes, forState: .Normal)
			self.seasonsSegment.addTarget(self, action: "seasonSegmentChanged:", forControlEvents: UIControlEvents.ValueChanged)
			self.seasonsScroll.addSubview(self.seasonsSegment)
			self.seasonsScroll.contentSize = CGSizeMake(self.seasonsSegment.frame.width+40, self.seasonsSegment.frame.height+10)
			self.seasonsSegment.frame.origin.y = 10
			self.seasonsSegment.frame.origin.x = 30
			
			//MARK: Setup background image and poster
			guard let tvdbtoken = Defaults[.TVDBToken], tvdbid = self.show?.tvdb_id else {
				print("TVDB Token not set or TVDB ID not present. Using default assets")
				self.setDefaultBackground()
				self.setDefaultPoster()
				self.getLatestSeason()
				return
			}
			print("Setting background and poster")
			self.getBackgroundImage(tvdbid, tvdbtoken: tvdbtoken) {
				TVDB().getShow(tvdbid, token: tvdbtoken) { showResponse, error in
					if let show = showResponse {
						for genre in show["data"]["genre"] {
							let g = GenreType(rawValue: String(genre.1))
							if let gType = g {
								let string = self.genre.text?.stringByAppendingFormat("%@ ", "\(gType.translate())")
								self.genre.text = string
							}
						}
					}
					print("Done getting data from TVDB")
				}
				// This is now unused. We're getting episodes and posters based on season switch
//				self.getPoster(tvdbid, tvdbtoken: tvdbtoken, subKey: self.seasons[self.seasonsSegment.selectedSegmentIndex].seasonNumber) {
//					self.getTVDBEpisodes(tvdbid, tvdbtoken: tvdbtoken) {
//						self.getLatestSeason()
//					}
//				}
			}
		}
	}
	
	func setDefaultBackground() {
		self.backgroundImage.image = UIImage(named: "default-background")
	}
	
	func setDefaultPoster() {
		if let sid = self.show?.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg")!
			self.poster.af_setImageWithURL(URL, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
		}
	}
	
	func getLatestSeason() {
		let latestSeason = seasons.maxElement({ $0.seasonNumber < $1.seasonNumber })
		filterSeason((latestSeason?.seasonNumber)!)
	}
	
	func seasonSegmentChanged(sender : UISegmentedControl) {
		let seasonIndex = self.seasons[sender.selectedSegmentIndex].seasonNumber
		print("Season changed to \(seasonIndex)")
		filterSeason(seasonIndex)
	}
	
	func filterSeason(season: Int) {
		var episodes = [Episode]()
		for episode in self.allEpisodes {
			if episode.season == season {
				episodes.append(episode)
			}
		}
		self.episodes = episodes
		UIView.transitionWithView(episodesCollection,
			duration:0.35,
			options:UIViewAnimationOptions.TransitionCrossDissolve,
			animations: { () -> Void in
				
			},
			completion: { done in
				if let tvdbtoken = Defaults[.TVDBToken], tvdbid = self.show?.tvdb_id {
					self.getPoster(tvdbid, tvdbtoken: tvdbtoken, subKey: season) {
						self.getTVDBEpisodes(tvdbid, tvdbtoken: tvdbtoken, season: season) {
							self.episodesCollection.reloadData()
						}
					}
				}
		})
	}
	
	// MARK: - TVDB Stuff
	
	func getBackgroundImage(tvdb: Int, tvdbtoken: String, callback: () -> ()) {
		
		TVDB().getImage(tvdb, token: tvdbtoken, type: "fanart", resolution: "1920x1080", subKey: nil) { bgResponse, error in
			if let _ = error {
				print("Error getting background image")
				self.setDefaultBackground()
				callback()
			}
			
			guard let bgResponse = bgResponse else {
				self.setDefaultBackground()
				callback(); return
			}
			let object = bgResponse["data"].first
			if let bgImage = object {
				guard let url = NSURL(string: "\(Config.tvdb.baseURL)\(bgImage.1["fileName"])") else {
					callback()
					return
				}
				// Works, but is VERY processor expensive
//				self.backgroundImage.af_setImageWithURL(url, placeholderImage: nil, filter: BlurFilter(blurRadius: 1))
				self.backgroundImage.af_setImageWithURL(url)
				let lightBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				let lightBlurView = UIVisualEffectView(effect: lightBlur)
				lightBlurView.frame = self.backgroundImage.bounds
				self.backgroundImage.addSubview(lightBlurView)
				callback()
			} else {
				self.setDefaultBackground()
				callback()
			}
		}
		
	}
	
	func getPoster(tvdb: Int, tvdbtoken: String, subKey: Int?, callback: () -> ()) {
		TVDB().getImage(tvdb, token: tvdbtoken, type: "season", resolution: nil, subKey: subKey) { bgResponse, error in
			guard let bgResponse = bgResponse else { callback(); return }
			let object = bgResponse["data"].first
			if let bgImage = object {
				guard let url = NSURL(string: "\(Config.tvdb.baseURL)\(bgImage.1["fileName"])") else {
					self.setDefaultPoster()
					callback()
					return
				}
//				self.posterURL = NSURL()
				self.poster.af_setImageWithURL(url, placeholderImage: nil, imageTransition: .CrossDissolve(0.2))
				callback()
			} else {
				self.setDefaultPoster()
				callback()
			}
		}
	}
	
	func getTVDBEpisodes(tvdb: Int, tvdbtoken: String, season: Int?, callback: () -> ()) {
		
		TVDB().getEpisodes(tvdb, token: tvdbtoken, season: season) { response, error in
			guard let objects = response else { callback(); return }
			self.TVDBEpisodes = objects
			callback()
		}
	}
	
	func updateEpisodeWatchedStatus(index: NSIndexPath, status: Bool) {
		let cell = episodesCollection.cellForItemAtIndexPath(index) as! EpisodeCollectionViewCell
		cell.screenshot.layer.borderWidth = status == true ? 0 : 3
		episodes[index.row].watched = status
	}
	
	func updateAllEpisodesAsWatched() {
		for cell in episodesCollection.visibleCells() as! [EpisodeCollectionViewCell] {
			cell.screenshot.layer.borderWidth = 0
		}
		for (index, _) in episodes.enumerate() {
			episodes[index].watched = true
		}
	}
	
	// MARK: - Soap4me Stuff
	
	
	func getEpisodes(token: String, show: Int, callback: () -> ()) {
		var seasons = [Season]()
		API().getEpisodes(token, show: show) { objects, error in
			if let result = objects {
				for episode in result {
					let s = Season(number: episode.season!, id: episode.season_id!)
					if !seasons.contains(s) { seasons.append(s) } // Since Season is Equatable :)
				}
				self.seasons = seasons
				self.allEpisodes = result
				callback()
			}
		}
	}

	
	/*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "scheduleSegue" {
			if let destination = segue.destinationViewController as? ScheduleTableViewController {
				destination.sid = show?.sid
				destination.token = self.token
			}
		}
	}*/

	// MARK: - Episodes Collection View Data Source and Delegate
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return episodes.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell: EpisodeCollectionViewCell?
		if cell == nil {
			cell = episodesCollection.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? EpisodeCollectionViewCell
		}
		let episode = episodes[indexPath.row]
		var version = [Version]()
		let screenshot = UIImage(named: "default-screenshot")
		let TVDBEpisode = TVDBEpisodes.filter {$0.airedEpisodeNumber == episode.episode && $0.airedSeason == episode.season}.first

		if let tvdbid = show?.tvdb_id, eid = TVDBEpisode?.id {
			if let url = NSURL(string: "\(Config.tvdb.baseURL)episodes/\(tvdbid)/\(eid).jpg") {
				cell?.screenshot.af_setImageWithURL(url, placeholderImage: screenshot, imageTransition: .CrossDissolve(0.2))
			}
		} else {
			cell?.screenshot.image = screenshot
		}
		cell?.episodeTitle.text = String(episode.episode!)+". "+(episode.title_en?.decodeEntity())!
		
		cell?.screenshot.layer.borderColor = UIColor.whiteColor().CGColor
		cell?.screenshot.layer.borderWidth = episode.watched == true ? 0 : 3
		
		if Defaults[.subtitles] == false { // Translated version
			version = episode.version.filter{$0.translate != Translation.Subtitles.rawValue}
		} else { // Subtitled original version
			version = episode.version.filter{$0.translate == Translation.Subtitles.rawValue}
		}
		if version.count > 0 {
//			cell?.translate.text = version[0].translate
			cell?.episodeTitle.textColor = UIColor.whiteColor()
//			cell?.episodeNumber.textColor = UIColor.blackColor()
		} else {
//			cell?.translate.text = "-"
			cell?.episodeTitle.textColor = UIColor.grayColor()
//			cell?.episodeNumber.textColor = UIColor.grayColor()
		}
		return cell!
	
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let episode = episodes[indexPath.row]
		var version = [Version]()
		if Defaults[.subtitles] == false { // Translated version
			version = episode.version.filter{$0.translate != Translation.Subtitles.rawValue}
		} else { // Subtitled original version
			version = episode.version.filter{$0.translate == Translation.Subtitles.rawValue}
		}
		
		let alert = UIAlertController(title: "Что будем делать?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
		
		for button in version {
			let button = UIAlertAction(title: "Смотреть эпизод в "+button.quality!, style: UIAlertActionStyle.Default) { action in
				if let videohash = button.hash, eid = button.eid, sid = episode.sid {
					
					let hashString =  md5(string: "\(self.token)\(eid)\(sid)\(videohash)")
					let url = "\(Config.URL.cdn)/\(self.token)/\(eid)/\(hashString)/"
					API().callback(hashString, token: self.token, eid: eid) { result in
						let player = AVPlayer(URL: NSURL(string: url)!)
						let playerController = self.storyboard?.instantiateViewControllerWithIdentifier("player") as! AVPlayerViewController
						playerController.player = player
						self.presentViewController(playerController, animated: true, completion: nil)
						playerController.player?.play()
					}
					
				}
			}
			alert.addAction(button)
		}
		let watchedTitle = episode.watched == true ? "Отметить эпизод непросмотренным" : "Отметить эпизод как просмотренный"
		var newWatchedStatus = false
		if let currentWatchedStatus = episode.watched {
			newWatchedStatus = !currentWatchedStatus
		}
		let watchedButton = UIAlertAction(title: watchedTitle, style: UIAlertActionStyle.Default) { (btn) -> Void in
			API().markWatched(self.token, episode: (version.first?.eid)!, isWatched: newWatchedStatus) {response, error in
				if let _ = response {
					self.updateEpisodeWatchedStatus(indexPath, status: newWatchedStatus)
				}
			}
		}
		alert.addAction(watchedButton)

		let watchedAllButton = UIAlertAction(title: "Отметить весь сезон как просмотренный", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
			API().markAllWatched(self.token, show: episode.sid!, season: episode.season!) { response, error in
				if let _ = response {
					self.updateAllEpisodesAsWatched()
				}
			}
		}
		alert.addAction(watchedAllButton)
		
		let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Destructive) { (btn) -> Void in
			
		}
		alert.addAction(cancelButton)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let next = context.nextFocusedView as? EpisodeCollectionViewCell {
			next.setNeedsUpdateConstraints()
			UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: .CurveEaseIn, animations: {
				next.transform = CGAffineTransformMakeScale(1.2,1.2)
				}, completion: { done in
			})
		}
		
		if let prev = context.previouslyFocusedView as? EpisodeCollectionViewCell {
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
