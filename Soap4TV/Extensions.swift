//
//  String.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension String {
	var count: Int { return self.characters.count }
}

extension DefaultsKeys {
	static let token = DefaultsKey<String?>("token")
	static let till = DefaultsKey<Int?>("till")
	static let sid = DefaultsKey<String?>("sid")
}