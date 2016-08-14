//
//  PlayerViewController.swift
//  Soap4TV
//
//  Created by Peter on 16/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


/**
*  Delegate protocol
*/
protocol PlayerViewControllerDelegate {
	/**
	Did play most of episode
	
	- parameter episode: episode
	*/
	func didPlayMostOfEpisode(episode: Episode)
}


/// Player View Controller
class PlayerViewController: AVPlayerViewController {
	
	/// MARK: - Properties
	
	// Video URL
	var videoURL : String!
	// Playback time observer
	var playerObserver: AnyObject!
	
	// TV Episode
	var episode: Episode!
	
	// Delegate
	var playerDelegate: PlayerViewControllerDelegate?
	
	// First play flag
	var firstPlay = true
	
	
	/// MARK: - Overrided
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
		
		
		let url = NSURL(string: videoURL)
		self.player = AVPlayer(URL: url!)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// check if can continue playing
		if self.firstPlay == true {
			let lastPosition = NSUserDefaults.standardUserDefaults().numberForKey((self.episode.version.first?.eid)!)
			
			if lastPosition != nil {
				
				let alertController = UIAlertController(title: "", message: "Продложить воспроизведение?", preferredStyle: .Alert)
				
				let continueAction = UIAlertAction(title: "Продолжить", style: .Default, handler: { (action) in
					let time = CMTime(seconds: lastPosition!.doubleValue, preferredTimescale: 1000)
					self.player?.seekToTime(time)
					self.player!.play()
				})
				
				let startFromBeginAction = UIAlertAction(title: "Начать сначала", style: .Default, handler: { (action) in
					self.player!.play()
				})
				
				alertController.addAction(continueAction)
				alertController.addAction(startFromBeginAction)
				
				self.presentViewController(alertController, animated: true, completion: {
					
				})
			} else {
				self.player!.play()
			}
			
			self.firstPlay = false
		} else {
			
			self.player!.play()
			
		}
		
		self.addPlayerPeriodicObserver()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.removePlayerPeriodicObserver()
		self.player!.pause()
		
		self.saveCurrentPosition()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		self.removePlayerPeriodicObserver()
		self.player = nil
	}
	
}


// MARK: - Notifications
extension PlayerViewController {
	
	/**
	Application will resign active notification recieved
	
	- parameter notification: notification
	*/
	func appWillResignActive(notification: NSNotification) {
		self.saveCurrentPosition()
	}
}


// MARK: - Self methods
extension PlayerViewController {
	
	/**
	Save current video position
	*/
	private func saveCurrentPosition() {
		let currentTime = Double(CMTimeGetSeconds(self.player!.currentTime()))
		NSUserDefaults.standardUserDefaults().setValue( NSNumber(double: currentTime), forKey: (self.episode.version.first?.eid)!)
	}
	
	/**
	Add player periodic observer to check if we played 80% of video to mark episode as watched
	*/
	func addPlayerPeriodicObserver() {
		
		removePlayerPeriodicObserver()
		
		// Time limit to play up until.
		let duration = self.player!.currentItem!.duration
		
		if duration.value == 0 {
			delay(2.0) {
				self.addPlayerPeriodicObserver()
			}
			
			return
		}
		
		
		// Time interval to check video playback.
		let interval = CMTime(seconds: 1.0, preferredTimescale: 1000)
		
		let durationInSeconds = CMTimeGetSeconds(duration)
		let oneThird  = 20 * durationInSeconds / 100
		let limit = CMTime(seconds: oneThird, preferredTimescale: 1000)
		let maxTime = duration - limit
		
		// Schedule the event observer.
		playerObserver = player?.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { [unowned self] time in
			
			if self.player!.currentTime() >= maxTime {
				
				self.removePlayerPeriodicObserver()
				
				if self.playerDelegate != nil {
					self.playerDelegate?.didPlayMostOfEpisode(self.episode)
				}
			}
		}
	}
	
	/**
	Remove player periodic observer
	*/
	func removePlayerPeriodicObserver() {
		
		if let playerObserver = self.playerObserver {
			self.player?.removeTimeObserver(playerObserver)
		}
		
		self.playerObserver = nil
	}
	
}
