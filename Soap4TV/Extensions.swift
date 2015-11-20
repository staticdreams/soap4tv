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
	static let login = DefaultsKey<String?>("login")
	static let password = DefaultsKey<String?>("password")
	static let token = DefaultsKey<String?>("token")
	static let till = DefaultsKey<Int?>("till")
	static let sid = DefaultsKey<String?>("sid")
	static let quality = DefaultsKey<String?>("quality")
	static let translation = DefaultsKey<String?>("translation")
	static let subtitles = DefaultsKey<Bool?>("subtitles")
	static let like = DefaultsKey<[Int]?>("like")
}

func delay(delay:Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delay * Double(NSEC_PER_SEC))
		),
		dispatch_get_main_queue(), closure)
}

func md5(string string: String) -> String {
	var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
	if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
		CC_MD5(data.bytes, CC_LONG(data.length), &digest)
	}
	
	var digestHex = ""
	for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
		digestHex += String(format: "%02x", digest[index])
	}
	
	return digestHex
}