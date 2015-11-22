//
//  MainNavigationController.swift
//  Soap4TV
//
//  Created by Peter on 18/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Chronos

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, UISearchControllerDelegate {

	var showsController = TVShowCollectionController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate = self
		
		NSTimer.every(55.minute) { // just to be sure we have enough time
			self.registerTokenRefresh()
		}

		let controllers = self.viewControllers
		
		for (index, controller) in controllers!.enumerate() {
			if let tvshowController = controller as? TVShowCollectionController {
				if index == 1 {
					tvshowController.currentView = .AllShows
					showsController = tvshowController
				}
				else if index == 2 {
					tvshowController.currentView = .MyShows
				}
				else if index == 3 {
					tvshowController.currentView = .FavShows
				}
				else {return}
			}
//			if let search = controller as? SearchViewController {
//				let searchController = UISearchController(searchResultsController: showsController)
//				searchController.searchResultsUpdater = showsController
//			}
		}
		
//		let searchController = UISearchController(searchResultsController: showsController)
//		searchController.searchResultsUpdater = showsController
//		searchController.hidesNavigationBarDuringPresentation = false
//		
//		let searchPlaceholderText = NSLocalizedString("Enter keyword (e.g. iceland)", comment: "")
//		searchController.searchBar.placeholder = searchPlaceholderText
//		
//		let searchItem = UITabBarItem(title: "Search", image: nil, selectedImage: nil)
//		searchController.tabBarItem = searchItem
//		
//		let searchContainer = UISearchContainerViewController(searchController: searchController)
//		let navController = UINavigationController(rootViewController: searchContainer)
//		controllers?.append(searchContainer)
		
//		controllers?.append(searchController)
//		self.viewControllers = controllers
    }
	
	func registerTokenRefresh() {
			
			if Defaults.hasKey(.TVDBToken) {
				guard let token = Defaults[.TVDBToken] else {
					print("No token has been saved...?")
					return
				}
				TVDB().refresh(token) { result, error in
					if let error = error {
						print("Failed to refresh token for TVDB: \(error)")
					}
					if let result = result {
						if result["token"] != nil {
							print("Alrighty! Token refreshed!")
							Defaults[.TVDBToken] = result["token"].stringValue
						}
					}
				}
			} else {
				print("No TVDB token has been previously registered")
			}
	
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
