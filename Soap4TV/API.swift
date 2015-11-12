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

struct API {
	
	func login(login: String, password:String, completionHandler: (responseObject: JSON?, error: ErrorType?) -> ()) {
		let headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		let parameters = ["login": login, "password": password, "allow_nonpro": 1]
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
	
	func getTVShows(token: String, completionHandler: (responseObject: [TVShow]?, error: ErrorType?) -> ()) {
		let headers = [
			"X-Api-Token": token,
			"User-Agent": "xbmc for soap",
			"Accept-Language": "ru",
			"Connection": "keep-alive"
		]
		Alamofire.request(.GET, Config.URL.base+"/api/soap", headers: headers)
			.responseArray { (response: Response<[TVShow], NSError>) in
				switch response.result {
				case .Success(let data):
					completionHandler(responseObject: data, error: nil)
				case .Failure(let error):
					completionHandler(responseObject: nil, error: error)
				}
		}
	}
	

}