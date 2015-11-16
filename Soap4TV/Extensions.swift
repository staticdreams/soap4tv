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

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
}

extension Array where Element : Hashable {
	var unique: [Element] {
		return Array(Set(self))
	}
}

extension Array {
	var last: Element {
		return self[self.endIndex - 1]
	}
}

extension SequenceType where Generator.Element: Equatable {
	func contains(val: Self.Generator.Element?) -> Bool {
		if val != nil {
			for item in self {
				if item == val {
					return true
				}
			}
		}
		return false
	}
}

extension DefaultsKeys {
	static let token = DefaultsKey<String?>("token")
	static let till = DefaultsKey<Int?>("till")
	static let sid = DefaultsKey<String?>("sid")
	static let quality = DefaultsKey<String?>("quality")
	static let translation = DefaultsKey<String?>("translation")
	static let subtitles = DefaultsKey<Bool?>("subtitles")
}

func delay(delay:Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delay * Double(NSEC_PER_SEC))
		),
		dispatch_get_main_queue(), closure)
}