//
//  String+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/5.
//

import Foundation
import CommonCrypto

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    func localized(withTableName tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: self)
    }
    // 轉換server給的app version 到正常的版號
    func realVersion() -> String {
        var v = self
        v.removeFirst()
        let firstIndex = v.index(v.startIndex, offsetBy: 1)
        let secIndex = v.index(after: firstIndex)
        let lastIndex = v.index(v.endIndex, offsetBy: -3)
        let first = v[...firstIndex]
        let second = v[secIndex..<lastIndex]
        let last = v[lastIndex...]
        return "\(Int(first)!).\(Int(second)!).\(Int(last)!)"
    }
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    
    func toDouble() -> Double {
        return Double(self) ?? 0.0
    }
   
    
    // 往前補0
    func paddingZeroBeforePrefix(_ formatWidth: Int) -> String {
        let num: Float = Float(self) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.formatWidth = formatWidth
        formatter.paddingPosition = .beforePrefix
        formatter.paddingCharacter = "0"
        let str = formatter.string(from: NSNumber(value: num)) ?? "0"
        return str
    }
    
    // 1 返回字数
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,options: NSRegularExpression.Options = []) -> String
    {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
    
    /// convert html to string
    func stripHTML() -> String {
        let htmlReplaceString  =   ["<[^>]+>","\n\n&nbsp","\n"]
        var str = self
        for html in htmlReplaceString {
            str = str.replacingOccurrences(of: html, with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        }
        return str
    }
    
    func formatterDateString(currentFormat: DateFormat, to format: DateFormat) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = currentFormat.rawValue
        let date =  dateformatter.date(from: self)!
        dateformatter.dateFormat = format.rawValue
        let dateStr = dateformatter.string(from: date)
        return dateStr
    }
    
    /// 數字格式轉換你要的單位
    ///
    /// - Parameters:
    ///   - style: 單位類型
    ///   - minimumFractionDigits: 最少到小數第幾位
    /// - Returns: String
    func numberFormatter(_ style: NumberFormatter.Style , _ minimumFractionDigits: Int = 2, locale: Locale = Locale(identifier: "zh_Hans_CN")) -> String {
        var newString = ""
        if self.contains(",")
        {
            for char in self
            {
                if char != ","
                {
                    newString += String(char)
                }
            }
        }else
        {
            newString = self
        }
        let num: Double = Double(newString) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = style
//        formatter.locale = locale
        formatter.minimumFractionDigits = minimumFractionDigits > 1 ? 2 : minimumFractionDigits
        formatter.maximumFractionDigits = minimumFractionDigits
        let str = formatter.string(from: NSNumber(value: num)) ?? "0.00"
        return str
    }
    func filterDecimal() -> String
    {
        var newString = ""
        if self.contains(",")
        {
            for char in self
            {
                if char != ","
                {
                    newString += String(char)
                }
            }
        }else
        {
            newString = self
        }
        return newString
    }
    func numberFormatterOnlyStyle(_ style: NumberFormatter.Style) -> String
    {
        let num: Double = Double(self) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = style
//        formatter.locale = nil
        formatter.maximumFractionDigits = 8
        let str = formatter.string(from: NSNumber(value: num)) ?? "0"
        return str
    }
    //Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }
    
    //Range转换为NSRange
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
                                     limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func toBankNo() ->String {
        var str = self
        switch count {
        case 0,1,2,3:
             break
        case 4,5,6:
            let maskCount = count - 3
            let lastThree = str.dropFirst(maskCount)
            str = "\("*".repeatStr(maskCount))\(lastThree)"
        default:
            let maskCount = count - 6
           let firstThree = str.dropLast(str.count - 3)
           let lastThree = str.dropFirst(str.count - 3)
            str = "\(firstThree)\("*".repeatStr(maskCount))\(lastThree)"
        }
        return str
    }
    
    func repeatStr(_ count:Int) -> String {
        guard count > 0 else {return ""}
        var result = ""
        for _ in 1...count {
            result += self
        }
        return result
    }
    
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    func customWidth(textSize:CGFloat = 14 , spaceWidth:CGFloat = 40) -> CGFloat {
        return NSString(string: self).size(withAttributes: [NSAttributedString.Key.font:Fonts.PlusJakartaSansMedium(textSize)]).width + spaceWidth
    }
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
