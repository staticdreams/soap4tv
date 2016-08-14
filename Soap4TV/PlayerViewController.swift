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
	
	
	/// MARK: - Overrided
	override func viewDidLoad() {
		super.viewDidLoad()
		let url = NSURL(string: videoURL)
		player = AVPlayer(URL: url!)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		player!.play()
		
		self.addPlayerPeriodicObserver()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.removePlayerPeriodicObserver()
		self.player!.pause()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		self.removePlayerPeriodicObserver()
		player = nil
	}
	
}


// MARK: - Self methods
extension PlayerViewController {
	
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
			player?.removeTimeObserver(playerObserver)
		}
		
		self.playerObserver = nil
	}
	
}
