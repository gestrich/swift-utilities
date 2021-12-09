//
//  StringTools.swift
//  FFIOSTools
//
//  Created by Bill Gestrich on 10/14/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public extension String {
    
    func getPartBefore(toSearch: String) -> String {
        
        var toRet = ""
        if let range = self.range(of: toSearch) {
            toRet = String(self[..<range.lowerBound])
        }
        
        return toRet
    }
    
    func getPartBeforeAndIncluding(toSearch: String) -> String {
        
        var toRet = ""
        if let range = self.range(of: toSearch) {
            toRet = String(self[..<range.upperBound])
        }
        
        return toRet
    }

    func getPartAfter(toSearch: String) -> String {
        
        var toRet = ""
        if let range = self.range(of: toSearch) {
            toRet = String(self[range.upperBound...])
        }    
        
        return toRet
    }
    
    func getPartAfterAndIncluding(toSearch: String) -> String {
        
        var toRet = ""
        if let range = self.range(of: toSearch) {
            toRet = String(self[range.lowerBound...])
        }
        
        return toRet
    }
    
}


public extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
}


//https://stackoverflow.com/questions/27327067/append-text-or-data-to-text-file-in-swift

public extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8) ?? Data()
        try data.append(fileURL: fileURL)
    }
}

public extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
