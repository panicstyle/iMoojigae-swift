//
//  Utils.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation

class Utils {
    static func numberOfMatches(_ str: String, regex: String) -> Int {
        let range = NSRange(str.startIndex..., in: str)
        let regex = try! NSRegularExpression(pattern: regex)
        return regex.numberOfMatches(in: str, options: [], range: range)
    }
    
    static func findStringRegex(_ str: String, regex: String) -> String {
        let range = NSRange(str.startIndex..., in: str)
        let regex = try! NSRegularExpression(pattern: regex)
        let findRange = regex.rangeOfFirstMatch(in: str, options:[], range: range)
        if findRange.location == NSNotFound {
            return ""
        }
        let r2 = Range(findRange, in: str)
        return String(str[r2!])
    }
    
    static func replaceStringHtmlTag(_ str: String) -> String {
        return str
    }
}
