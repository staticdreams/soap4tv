//
//  SearchViewController.swift
//  Soap4TV
//
//  Created by Peter on 17/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit

class SearchViewController: UISearchController, UISearchControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let collectionController = storyboard?.instantiateViewControllerWithIdentifier("tvshowsController") as! TVShowCollectionController
		self.searchResultsUpdater = collectionController
		self.hidesNavigationBarDuringPresentation = false
		
		let searchPlaceholderText = NSLocalizedString("Поиск", comment: "")
		self.searchBar.placeholder = searchPlaceholderText
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
