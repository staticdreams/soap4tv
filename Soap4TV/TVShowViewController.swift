//
//  TVShowViewController.swift
//  Soap4TV
//
//  Created by Peter on 12/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

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
//	
//	@IBOutlet weak var qualitySwitch: UISegmentedControl!
	@IBOutlet weak var translationSwitch: UISegmentedControl!
//

	@IBOutlet weak var cover: UIImageView!
	@IBOutlet weak var showtitle: UILabel!
	@IBOutlet weak var showtitle_ru: UILabel!
	@IBOutlet weak var introduction: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var seasonContainer: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//currentTranslation = Defaults.hasKey(.quality) ? Defaults[.quality] : Translation().rawValue
		
		showtitle.text = show?.title!
		showtitle_ru.text = show?.title_ru!
		introduction.text = show?.description!
		if let sid = show?.sid {
			let URL = NSURL(string: "\(Config.URL.covers)/soap/big/\(sid).jpg")!
			let placeholderImage = UIImage(named: "placeholder")!
			cover.af_setImageWithURL(URL, placeholderImage: placeholderImage)
		}
		self.tableView.registerNib(UINib(nibName: "EpisodeTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
		token = Defaults[.token]!
		Defaults[.quality] = Defaults.hasKey(.quality) ? Defaults[.quality] : Quality.HD.rawValue
		Defaults[.subtitles] = Defaults.hasKey(.subtitles) ? Defaults[.subtitles] : false
//		Defaults[.translation] = Defaults.hasKey(.translation) ? Defaults[.translation] : Translation().rawValue
		loadEpisodes()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		translationSwitch.selectedSegmentIndex = Defaults[.subtitles] == false ? 0 : 1
	}

	override var preferredFocusedView: UIView? {
		return self.tableView
	}
 
//	@IBAction func qualityChanged(sender: UISegmentedControl) {
//		print(sender)
//		switch qualitySwitch.selectedSegmentIndex {
//			case 0:
//				print("Quality HD")
//			break
//			case 1:
//				print("Quality SD")
//			break
//			default:
//				
//			break
//		}
//	}
//	
	
	@IBAction func translationChanged(sender: UISegmentedControl) {
		switch translationSwitch.selectedSegmentIndex {
		case 0:
			Defaults[.subtitles] = false
			break
		case 1:
			Defaults[.subtitles] = true
			break
		default:
			
			break
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
					// Get latest season
//						if subtitles {
//							if episode.translate == Translation.Subtitles.rawValue {
//								episodes.append(episode)
//							}
//						} else {
//							if episode.translate != Translation.Subtitles.rawValue {
//								episodes.append(episode)
//							}
//						}
						//}
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
		print("Season selected \(season)")
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
	
	func filterTranslation() {
	
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
		cell.title.text = episode.title_en
		cell.episode.text = String(episode.episode!)
//		cell.quality.text = episode.quality
//		cell.translate.text = episode.version?.translate
		return cell
	}

}
