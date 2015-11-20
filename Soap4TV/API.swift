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

struct API {
	
	func login(login: String, password:String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let parameters = ["login": login, "password": password, "allow_nonpro": 1]
		
		Alamofire.request(.GET, Config.URL.base+"/logout/", headers: headers)
			.responseJSON { response in
			
		}
		
		Alamofire.request(.POST, Config.URL.base+"/login", headers: headers, parameters:parameters as? [String : AnyObject])
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
		Alamofire.request(.POST, Config.URL.base+"/callback", parameters:parameters)
			.responseJSON { response in
				switch response.result {
					case .Success(let data):
						completionHandler(responseObject: JSON(data), error: nil)
					case .Failure(let error):
						completionHandler(responseObject: nil, error: error)
				}
		}
	}
	
	func getTVShows(token: String, view: PresentedView, completionHandler: (responseObject: [TVShow]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let suffix = view == .MyShows ? "/my/" : ""
		Alamofire.request(.GET, Config.URL.base+"/api/soap"+suffix, headers: headers)
			.responseArray { (response: Response<[TVShow], NSError>) in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: data, error: nil)
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
		
		Alamofire.request(.GET, Config.URL.base+"/api/episodes/"+String(show), headers: headers)
			.responseJSON { response in
				var array = [Episode]()
				switch response.result {
				case .Success(let data):
					let episodes = JSON(data)
					var currentEpisode = -1
					var entry: Episode?
					for (index,episode):(String, JSON) in episodes {
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
							if Int(index)!+1 == episodes.count {
								array.append(entry!)
							}
							// if last - write
						} else if currentEpisode == episode["episode"].intValue {
//							print("this is where we apend existing episode with new entry")
							entry?.version.append(version)
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
		Alamofire.request(.GET, url, headers: headers)
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
	

}