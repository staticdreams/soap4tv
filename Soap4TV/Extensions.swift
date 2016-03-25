//
//  String.swift
//  Soap4TV
//
//  Created by Peter on 09/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension String{
	func decodeEntity() -> String{
		let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
		let attributedOptions : [String: AnyObject] = [
			NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
			NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
		]
		let attributedString = try! NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
		return attributedString.string
	}
	
	func stripHTML() -> String {
		let htmlStringData = self.dataUsingEncoding(NSUTF8StringEncoding)!
		let options: [String: AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding]
		let attributedHTMLString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
		return attributedHTMLString.string
	}
}

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
	static let TVDBToken = DefaultsKey<String?>("tvdbtoken")
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

func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
	
	let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
	
	let contextSize: CGSize = contextImage.size
	
	var posX: CGFloat = 0.0
	var posY: CGFloat = 0.0
	var cgwidth: CGFloat = CGFloat(width)
	var cgheight: CGFloat = CGFloat(height)
	
	// See what size is longer and create the center off of that
	if contextSize.width > contextSize.height {
		posX = ((contextSize.width - contextSize.height) / 2)
		posY = 0
		cgwidth = contextSize.height
		cgheight = contextSize.height
	} else {
		posX = 0
		posY = ((contextSize.height - contextSize.width) / 2)
		cgwidth = contextSize.width
		cgheight = contextSize.width
	}
	
	let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
	
	// Create bitmap image from context using the rect
	let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
	
	// Create a new image based on the imageRef and rotate back to the original orientation
	let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
	
	return image
}


struct FixedSizeArray<T> {
	private var maxSize: Int
	private var defaultValue: T
	private var array: [T]
	private (set) var count = 0
	
	init(maxSize: Int, defaultValue: T) {
		self.maxSize = maxSize
		self.defaultValue = defaultValue
		self.array = [T](count: maxSize, repeatedValue: defaultValue)
	}
	
	subscript(index: Int) -> T {
		assert(index >= 0)
		assert(index < count)
		return array[index]
	}
	
	mutating func append(newElement: T) {
		assert(count < maxSize)
		array[count] = newElement
		count += 1
	}
	
	mutating func removeAtIndex(index: Int) -> T {
		assert(index >= 0)
		assert(index < count)
		count -= 1
		let result = array[index]
		array[index] = array[count]
		array[count] = defaultValue
		return result
	}
}


extension CollectionType {
	func last(count:Int) -> [Self.Generator.Element] {
		let selfCount = self.count as! Int
		if selfCount <= count - 1 {
			return Array(self)
		} else {
			return Array(self.reverse()[0...count - 1].reverse())
		}
	}
}

extension Array {
	func takeElements(element: Int) -> Array {
		var elementCount = element
		if (elementCount > count) {
			elementCount = count
		}
		return Array(self[0..<elementCount])
	}
}
extension NSDate {
	func sameDate(date: NSDate?) -> Bool {
		if let d = date {
			let calendar = NSCalendar.currentCalendar()
			if NSComparisonResult.OrderedSame == calendar.compareDate(self, toDate: d, toUnitGranularity: NSCalendarUnit.Day) {
				return true
			}
		}
		return false
	}
	
	func someDay(daysToAdd: Int) -> NSDate {
		let dateComponents: NSDateComponents = NSDateComponents()
		dateComponents.day = daysToAdd
		let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
		let day: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents, toDate: self, options:NSCalendarOptions(rawValue: 0))!
		return day
	}
	
	func dayOfTheWeek() -> Int {
		let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
		let myComponents = gregorianCalendar.components(.Weekday, fromDate: self)
		let weekDay = myComponents.weekday
		return weekDay
	}
}

extension UISegmentedControl {
	func replaceSegments(segments: Array<String>) {
		self.removeAllSegments()
		for segment in segments {
			self.insertSegmentWithTitle(segment, atIndex: self.numberOfSegments, animated: false)
		}
	}
}
