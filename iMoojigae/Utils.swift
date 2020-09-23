//
//  Utils.swift
//  iMoojigae
//
//  Created by dykim on 2020/09/19.
//  Copyright © 2020 dykim. All rights reserved.
//

import Foundation
import UIKit

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
    
    static func replaceStringRegex(_ str: String, regex: String, replace: String) -> String {
        let range = NSRange(str.startIndex..., in: str)
        let regex = try! NSRegularExpression(pattern: regex)
        let str2 = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: replace)
        return String(str2)
    }
    
    static func replaceStringHtmlTag(_ str: String) -> String {
        return str
    }

    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
