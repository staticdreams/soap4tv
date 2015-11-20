//
//  MainNavigationController.swift
//  Soap4TV
//
//  Created by Peter on 18/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class MainNavigationController: UITabBarController, UITabBarControllerDelegate, UISearchControllerDelegate {

	var showsController = TVShowCollectionController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate = self
		
		let controllers = self.viewControllers
		
		for (index, controller) in controllers!.enumerate() {
			if let tvshowController = controller as? TVShowCollectionController {
				if index == 0 {
					tvshowController.currentView = .AllShows
					showsController = tvshowController
				}
				else if index == 1 {
					tvshowController.currentView = .MyShows
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

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
