//
//  TVShow.swift
//  Soap4TV
//
//  Created by Peter on 11/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import ObjectMapper

struct TVShow: Mappable {
	
	var sid: Int?
	var title: String?
	var title_ru: String?
	var description: String?
	var year: Int?
	var imdb_rating: Float?
	var imdb_votes: Int?
	var imdb_id: String?
	var tvdb_id: Int?
	var status: Int?
	var kinopoisk_id: Int?
	var kinopoisk_votes: Int?
	var kinopoisk_rating: Float?
	var country: String?
	var tvmaze_id: Int?
	var watching: Bool?
	var unwatched: Bool?
	
	init?(_ map: Map){}
	
	let convertToInt = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
		guard let myInt = value else { return nil }
		return Int(myInt)
		}, toJSON: { (value: Int?) -> String? in
			return nil
	})
	
	let convertToFloat = TransformOf<Float, String>(fromJSON: { (value: String?) -> Float? in
		guard let myFloat = value else { return nil }
		return Float(myFloat)
		}, toJSON: { (value: Float?) -> String? in
			return nil
	})
	
	let convertToBool = TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
		guard let myBool = value else { return nil }
		return myBool == "1" ? true : false
		}, toJSON: { (value: Bool?) -> String? in
			return nil
	})
	
	mutating func mapping(map: Map) {
		sid <- (map["sid"], convertToInt)
		title <- map["title"]
		title_ru <- map["title_ru"]
		description <- map["description"]
		year <- (map["year"], convertToInt)
		imdb_rating <- (map["imdb_rating"], convertToFloat)
		imdb_votes <- (map["imdb_votes"], convertToInt)
		imdb_id <- map["imdb_id"]
		tvdb_id <- (map["tvdb_id"], convertToInt)
		status <- map["status"]
		kinopoisk_id <- (map["kinopoisk_id"], convertToInt)
		kinopoisk_votes <- (map["kinopoisk_votes"], convertToInt)
		kinopoisk_rating <- (map["kinopoisk_rating"], convertToFloat)
		country <- map["country"]
		tvmaze_id <- (map["tvmaze_id"], convertToInt)
		watching <- (map["watching"], convertToBool)
		unwatched <- (map["unwatched"], convertToBool)
	}
}


struct Schedule: Mappable {
	
	var episode: String?
	var date: String?
	var title: String?
	
	init?(_ map: Map){}
	
	mutating func mapping(map: Map) {
		title <- map["title"]
		date <- map["date"]
		episode <- map["episode"]
	}
}
