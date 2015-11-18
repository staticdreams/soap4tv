//
//  MainNavigationController.swift
//  Soap4TV
//
//  Created by Peter on 18/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class MainNavigationController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		let controllers = self.viewControllers
		
		for (index, controller) in controllers!.enumerate() {
			if let tvshowController = controller as? TVShowCollectionController {
				if index == 0 {
					tvshowController.currentView = .AllShows
				}
				if index == 1 {
					tvshowController.currentView = .MyShows
				}
			}
		}
		
		
//		if let showsController = controllers![0] as? TVShowCollectionController {
//			showsController.currentView = .AllShows
//		}
//		if let showsController = controllers![1] as? TVShowCollectionController {
//			showsController.currentView = .MyShows
//		}
    }
	
	// TODO: showAll should be a enum

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
