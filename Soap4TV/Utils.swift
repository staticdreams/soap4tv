//
//  Utils.swift
//  Soap4TV
//
//  Created by Sergei Armodin on 25.03.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import Foundation

/**
Лог-функция с выводом файла, метода и строки, откуда вызывается. Пример использования: DLog("привет")

- parameter message:      текст, который надо вывести
- parameter fullPath:     путь до файла, который вызывается
- parameter line:         номер строки в файле
- parameter functionName: название метода/функции вызова
*/
func DLog(message: AnyObject, fullPath: String = #file, line: Int = #line, functionName: String = #function) {
	let file = NSURL.fileURLWithPath(fullPath)
	print("\(file.pathComponents!.last) -> \(functionName) -> line \(line) : \(message)")
}
