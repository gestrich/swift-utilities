//
//  NSRegularExpressions+Utils.swift
//  swift-utilities
//
//  Created by Bill Gestrich on 11/17/19.
//

import Foundation

public extension NSRegularExpression {
    //TODO: For multi-line regex, this returns the last line currently.
    func stringMatch (toSearch: String, matchIndex: Int) -> String? {
        let nsstr = toSearch as NSString
        let all = NSRange(location: 0, length: nsstr.length)
        var match : String?
        self.enumerateMatches(in: toSearch, options: [], range: all) {
            (result : NSTextCheckingResult?, _, _) in
            if let r = result {
                if r.range(at: matchIndex).location != NSNotFound {
                    let result = nsstr.substring(with: r.range(at: matchIndex)) as String
                    match = result
                }
            }
        }
            
        return match
    }
    
    func stringMatches (toSearch: String, matchIndex: Int) -> [String] {
        let nsstr = toSearch as NSString
        let all = NSRange(location: 0, length: nsstr.length)
        var matches = [String]()
        self.enumerateMatches(in: toSearch, options: [], range: all) {
            (result : NSTextCheckingResult?, _, _) in
            if let r = result {
                if r.range(at: matchIndex).location != NSNotFound {
                    let result = nsstr.substring(with: r.range(at: matchIndex)) as String
                    matches.append(result)
                }
            }
        }
            
        return matches
    }
    
    func floatMatch (toSearch: String, matchIndex : Int) -> Float? {
        let stringCapture = self.stringMatch(toSearch: toSearch, matchIndex: matchIndex) ?? ""
        guard stringCapture != "" else {
            return nil
        }
        
        return Float(stringCapture)
    }
    
    func intMatch (toSearch: String, matchIndex : Int) -> Int? {
        let stringCapture = self.stringMatch(toSearch: toSearch, matchIndex: matchIndex) ?? ""
        guard stringCapture != "" else {
            return nil
        }
        
        return Int(stringCapture)
    }
    
}
