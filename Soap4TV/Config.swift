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
		static let base = "http://soap4.me"
		static let covers = "http://covers.s4me.ru"
		static let cdn = "http://storage.soap4.me"
	}
	
	struct tvdb {
		static let baseURL = "http://thetvdb.com/"
		static let vignettePath = "banners/fanart/vignette/"
	}
	
	static let maxNumberFeatured = 20
	
}