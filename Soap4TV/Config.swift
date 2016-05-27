//
//  Config.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import Foundation

struct Config {

	struct URL {
		static let base = "https://soap4.me"
		static let covers = "http://covers.soap4.me"
		static let cdn = "https://storage.soap4.me"
	}
	
	struct tvdb {
		static let baseURL = "https://thetvdb.com/banners/"
		static let apiURL = "https://api.thetvdb.com"
		static let username = "kernelpanic"
		static let userKey = "0D87CEDCEE0482F6"
		static let apikey = "229B5C0EC556FF90"
	}
	
	static let maxNumberFeatured = 20
	
}