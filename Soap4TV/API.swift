//
//  API.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireObjectMapper
import ObjectMapper


//
//var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//configuration.timeoutIntervalForRequest = 4 // seconds
//configuration.timeoutIntervalForResource = 4
//
//struct APIManager {
//	
//}


struct API {
	
	var manager : Alamofire.Manager?

	init() {
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		configuration.timeoutIntervalForRequest = 9 // seconds
		configuration.timeoutIntervalForResource = 9
		manager = Alamofire.Manager(configuration: configuration)
	}
	
	func login(login: String, password:String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let parameters = ["login": login, "password": password, "allow_nonpro": 1]
		
		manager?.request(.POST, Config.URL.base+"/login", headers: headers, parameters:parameters as? [String : AnyObject])
			.responseJSON { response in
			switch response.result {
			case .Success(let data):
				completionHandler(responseObject: JSON(data), error: nil)
			case .Failure(let error):
				completionHandler(responseObject: nil, error: error)
			}
		}
	}
	
	func callback(hash: String, token: String, eid: String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let parameters = ["do": "load", "what": "player", "hash": hash, "token": token, "eid": eid]
		manager?.request(.POST, Config.URL.base+"/callback", parameters:parameters)
			.responseJSON { response in
				switch response.result {
					case .Success(let data):
						completionHandler(responseObject: JSON(data), error: nil)
					case .Failure(let error):
						completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getTVShows(token: String, view: PresentedView?, completionHandler: (responseObject: [TVShow]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let suffix = view == .MyShows ? "/my/" : ""
		manager?.request(.GET, Config.URL.base+"/api/soap"+suffix, headers: headers)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					var shows = [TVShow]()
					let tvshows = JSON(data)
					for (_,show):(String, JSON) in tvshows {
						let item = Mapper<TVShow>().map(show.dictionaryObject)
						if let entry = item {
							shows.append(entry)
						}
					}
					delay(0.5) {
						completionHandler(responseObject: shows, error: nil)
					}
				case .Failure(let error):
					print(error)
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getEpisodes(token: String, show: Int, completionHandler: (responseObject: [Episode]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		
		manager?.request(.GET, Config.URL.base+"/api/episodes/"+String(show), headers: headers)
			.responseJSON { response in
				var array = [Episode]()
				switch response.result {
				case .Success(let data):
					let episodes = JSON(data)
					var currentEpisode = -1
					var entry: Episode?
					let lastElement = episodes[episodes.count-1]
					for (_,episode):(String, JSON) in episodes {
						
						if episode["episode"].intValue != currentEpisode && entry != nil  { // we finished looping. adding & resetting.
//							print("and we're finaly writing single episode with all versions")
							array.append(entry!)
							entry = nil
						}
						
						var version = Version()
						version.hash = episode["hash"].stringValue
						version.quality = episode["quality"].stringValue
						version.translate = episode["translate"].stringValue
						version.eid = episode["eid"].stringValue
						
						if entry == nil { // Current episode has no version whatsoever
//							print("ok, this is a new episode: \(episode["episode"].intValue). Creating separate entry")
							entry = Mapper<Episode>().map(episode.dictionaryObject)
							entry?.version.append(version)
							if episode == lastElement  {
								array.append(entry!)
							}
							// if last - write
						} else if currentEpisode == episode["episode"].intValue {
//							print("this is where we apend existing episode with new entry")
							entry?.version.append(version)
							if episode == lastElement  {
								array.append(entry!)
							}
						}
						currentEpisode = episode["episode"].intValue
					
					}
					completionHandler(responseObject: array, error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
				
		}
	}
	
	func getSchedule(token: String, sid: Int, completionHandler: (responseObject: [Schedule]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let url = Config.URL.base+"/api/soap/shedule/"+String(sid)
		manager?.request(.GET, url, headers: headers)
			.responseArray { (response: Response<[Schedule], NSError>) in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: data, error: nil)
				case .Failure(let error):
					print(error)
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getFullSchedule(token: String, completionHandler: (responseObject: [Schedule]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let url = Config.URL.base+"/api/shedule/full/"
		manager?.request(.GET, url, headers: headers)
			.responseArray { (response: Response<[Schedule], NSError>) in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: data, error: nil)
				case .Failure(let error):
					print(error)
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func markWatched(token: String, episode: String, isWatched: Bool, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru"
		]
		let parameters = [
			"what": isWatched ? "mark_watched" : "mark_unwatched",
			"eid": episode,
			"token": token
		]
		let url = Config.URL.base+"/callback"
		manager?.request(.POST, url, headers: headers, parameters: parameters)
			.responseJSON { response in
				switch response.result {
					case .Success(let data):
						completionHandler(responseObject: JSON(data), error: nil)
					case .Failure(let error):
						completionHandler(responseObject: nil, error: error)
				}
			}
	}
	
	func markAllWatched(token: String, show: String, season: Int, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru"
		]
		let parameters = [
			"what": "mark_full",
			"sid": show,
			"season": String(season),
			"token": token
		]
		let url = Config.URL.base+"/callback"
		manager?.request(.POST, url, headers: headers, parameters: parameters)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func toggleWatch(token: String, show: String, status: Bool, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru"
		]
		let parameters = ["token": token]
		let action = status ? "watch" : "unwatch"
		let url = Config.URL.base+"/api/soap/\(action)/\(show)"
		manager?.request(.POST, url, headers: headers, parameters: parameters)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
}


struct TVDB {
	
	var manager : Alamofire.Manager?
	
	init() {
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		configuration.timeoutIntervalForRequest = 8 // seconds
		configuration.timeoutIntervalForResource = 8
		manager = Alamofire.Manager(configuration: configuration)
	}
	
	func login(login: String, userkey:String, apikey:String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = ["Content-Type": "application/json"]
		let parameters = ["username": login, "userkey": userkey, "apikey": apikey]
		
		manager?.request(.POST, Config.tvdb.apiURL+"/login", headers: headers, parameters:parameters, encoding: .JSON)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func refresh(token: String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/json",
			"Authorization": "Bearer \(token)"
		]
		manager?.request(.GET, Config.tvdb.apiURL+"/refresh_token", headers: headers)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getShow(showId: Int, token: String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/json",
			"Authorization": "Bearer \(token)",
			"Accept-Language": "en"
		]
		manager?.request(.GET, Config.tvdb.apiURL+"/series/"+String(showId), headers: headers)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getImage(showId: Int, token: String, type: String, resolution: String?, subKey: Int?, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/json",
			"Authorization": "Bearer \(token)",
			"Accept-Language": "en"
		]
		var parameters = ["keyType": type]
		if let res = resolution {
			parameters["resolution"] = res
		}
		if let key = subKey {
			parameters["subKey"] = String(key)
		}
		let URL = Config.tvdb.apiURL+"/series/"+String(showId)+"/images/query"
		manager?.request(.GET, URL, headers: headers, parameters: parameters)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: JSON(data), error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getEpisodes(showId: Int, token: String, season: Int?, completionHandler: (responseObject: [TVDBEpisode]?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/json",
			"Authorization": "Bearer \(token)",
			"Accept-Language": "en"
		]
		var parameters = ["page":"1"]
		if let s = season {
			parameters["airedSeason"] = String(s)
		}
		manager?.request(.GET, Config.tvdb.apiURL+"/series/"+String(showId)+"/episodes/query", headers: headers, parameters: parameters)
			.responseJSON { response in
				switch response.result {
				case .Success(let data):
					let objects = JSON(data)
					var episodes = [TVDBEpisode]()
					for (_,episode):(String, JSON) in objects["data"] {
						let item = Mapper<TVDBEpisode>().map(episode.dictionaryObject)
						if let entry = item {
							episodes.append(entry)
						}
					}
					completionHandler(responseObject: episodes, error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
			}
		}
		
	}
	
	
}
