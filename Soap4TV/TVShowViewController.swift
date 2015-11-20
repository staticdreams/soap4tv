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


class TVShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var show: TVShow?
	var episodes = [Episode]()
	var allEpisodes = [Episode]()
	var token = ""
	var numberOfSeasons = 0
	var seasons = [Season]() {
		didSet { loadSeasons() }
	}
	var currentTranslation: String?
	var seasonsController = SeasonsTableViewController()
	var qualityView: UIView!
	var playerController: AVPlayerViewController?
	var userLikes = [Int]()
	
	var currentShowLiked: Bool = false
	
	@IBOutlet weak var translationButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
	
	@IBOutlet weak var cover: UIImageView!
	@IBOutlet weak var showtitle: UILabel!
	@IBOutlet weak var showtitle_ru: UILabel!
	@IBOutlet weak var introduction: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		currentTranslation = Defaults.hasKey(.translation) ? Defaults[.translation] : Translation().rawValue
		currentShowLiked = Defaults.hasKey(.like) && Defaults[.like]!.contains(show?.sid) ? true : false
		userLikes = Defaults.hasKey(.like) ? Defaults[.like]! : []
		token = Defaults[.token]!
		Defaults[.quality] = Defaults.hasKey(.quality) ? Defaults[.quality] : Quality.HD.rawValue
		Defaults[.subtitles] = Defaults.hasKey(.subtitles) ? Defaults[.subtitles] : false
		
		showtitle.text = show?.title!
		showtitle_ru.text = show?.title_ru!
		introduction.text = show?.description!
		if let sid = show?.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg")!
			let placeholderImage = UIImage(named: "placeholder")!
			cover.af_setImageWithURL(URL, placeholderImage: placeholderImage)
		}
		self.tableView.registerNib(UINib(nibName: "EpisodeTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
		loadEpisodes()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let likeImage = currentShowLiked ? ButtonState.Dislike.image() :  ButtonState.Like.image()
		likeButton.setImage(likeImage, forState: UIControlState.Normal)
		let translationImage = Defaults[.subtitles]! ? ButtonState.Subtitle.image() :  ButtonState.Translation.image()
		translationButton.setImage(translationImage, forState: UIControlState.Normal)
	}

	override var preferredFocusedView: UIView? {
		return self.tableView
	}
	
	
	@IBAction func likeTapped(sender: AnyObject) {
		currentShowLiked = !currentShowLiked
		if currentShowLiked {
			userLikes.append((show?.sid)!)
		} else {
			userLikes = userLikes.filter() { $0 != show?.sid! }
		}
		Defaults[.like] = userLikes
		let image = currentShowLiked ? ButtonState.Dislike.image() :  ButtonState.Like.image()
		likeButton.setImage(image, forState: UIControlState.Normal)
	}

	@IBAction func translationTapped(sender: AnyObject) {
		if let state = Defaults[.subtitles] {
			Defaults[.subtitles] = !state
			let image = Defaults[.subtitles]! ? ButtonState.Subtitle.image() :  ButtonState.Translation.image()
			translationButton.setImage(image, forState: UIControlState.Normal)
			self.tableView.reloadData()
		}
	}

	/**
	Load all the episodes for current TV show and construct a list of Seasons
	*/
	func loadEpisodes() {
		guard let showId = show?.sid else {return}
		var seasons = [Season]()
		API().getEpisodes(token, show: showId) { objects, error in
			if let result = objects {
				for episode in result {
					let s = Season(number: episode.season!, id: episode.season_id!)
					if !seasons.contains(s) { seasons.append(s) } // Since Season is Equatable :)
				}
				self.seasons = seasons
				self.allEpisodes = result
				let latestSeason = seasons.maxElement({ $0.seasonNumber < $1.seasonNumber })
				delay(0.5) {
					self.seasonsController.currentSeason(latestSeason!)
				}
			}
		}
	}
	
	func filterSeason(season: Int) {
		var episodes = [Episode]()
		for episode in self.allEpisodes {
			if episode.season == season {
				episodes.append(episode)
			}
		}
		self.episodes = episodes
		UIView.transitionWithView(tableView,
			duration:0.35,
			options:UIViewAnimationOptions.TransitionCrossDissolve,
			animations: { () -> Void in
				self.tableView.reloadData()
			},
		completion: nil);
	}
	
	/**
	Loading Seasons list into Season TableView Controller
	*/
	func loadSeasons() {
		seasonsController.seasons = seasons
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "seasonsSegue" {
			if let destination = segue.destinationViewController as? SeasonsTableViewController {
				seasonsController = destination
				seasonsController.tvshowController = self
			}
		}
		if segue.identifier == "scheduleSegue" {
			if let destination = segue.destinationViewController as? ScheduleTableViewController {
				destination.sid = show?.sid
				destination.token = self.token
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK: TableView datasource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EpisodeTableViewCell
		let episode = episodes[indexPath.row]
		var version = [Version]()
		cell.title.text = episode.title_en
		cell.episode.text = String(episode.episode!)
		if Defaults[.subtitles] == false { // Translated version
			version = episode.version.filter{$0.translate != Translation.Subtitles.rawValue}
		} else { // Subtitled original version
			version = episode.version.filter{$0.translate == Translation.Subtitles.rawValue}
		}
		if version.count > 0 {
			cell.translate.text = version[0].translate
			cell.title.textColor = UIColor.blackColor()
			cell.episode.textColor = UIColor.blackColor()
			cell.userInteractionEnabled = true
		} else {
			cell.translate.text = "-"
			cell.title.textColor = UIColor.grayColor()
			cell.episode.textColor = UIColor.grayColor()
			cell.userInteractionEnabled = false
		}
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let episode = episodes[indexPath.row]
		var version = [Version]()
		if Defaults[.subtitles] == false { // Translated version
			version = episode.version.filter{$0.translate != Translation.Subtitles.rawValue}
		} else { // Subtitled original version
			version = episode.version.filter{$0.translate == Translation.Subtitles.rawValue}
		}
		
		let alert = UIAlertController(title: "Качество просмотра", message: "В каком качестве будем смотреть?", preferredStyle: UIAlertControllerStyle.Alert)

		for button in version {
			let button = UIAlertAction(title: button.quality, style: UIAlertActionStyle.Default) { action in
				if let videohash = button.hash, eid = button.eid, sid = episode.sid {
					
					let hashString =  md5(string: "\(self.token)\(eid)\(sid)\(videohash)")
					let url = "\(Config.URL.cdn)/\(self.token)/\(eid)/\(hashString)/"
					API().callback(hashString, token: self.token, eid: eid) { result in
//						print(result)
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
		let cancelButton = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Destructive) { (btn) -> Void in }
		alert.addAction(cancelButton)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}

}
