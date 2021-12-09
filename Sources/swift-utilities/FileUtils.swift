//
//  FileTools.swift
//  FFIOSTools
//
//  Created by Bill Gestrich on 10/14/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public func filenamesMatching(pattern: String, directory: String ) -> [String] {
    let filenames = try! FileManager.default.contentsOfDirectory(atPath: directory)
    
    var toRet = [String]()
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        print("Regex error in using pattern \(pattern)")
        return []
    }
    
    for filename in filenames {
        //TODO: This treats the 0 index match as matching the regex.
        //Need to read the docs on what the 0 match index is.
        if regex.stringMatch(toSearch: filename, matchIndex: 0) != nil {
            toRet.append(filename)
        }
    }
    
    return toRet
}

public func moveFile(source: String, destination: String) -> Bool{
    guard let _ = try? FileManager.default.moveItem(atPath: source, toPath: destination) else {
        print("Error moving file")
        return false
    }
    return true
}

public func replaceLinesAtFilePath(_ filePath: String, containing:String, newString: String) {
    
    guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else{
        return
    }
    
    let lineSeparator: Character = "\n"
    
    let lines = fileContents.split(separator: lineSeparator)
    var updatedLines = lines.map({String($0)})
    var index = 0
    var linesUpdated = false
    for part in lines {
        if part.contains(containing){
            updatedLines.remove(at: index)
            updatedLines.insert(newString, at: index)
            linesUpdated = true
        }
        index += 1
    }
    if linesUpdated {
        try? updatedLines.joined(separator: "\(lineSeparator)").write(toFile: filePath, atomically: true, encoding: .utf8)
    }
}

public func replaceOccurencesInFile(_ filePath: String, oldString:String, newString: String) {
    
    guard let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8) else{
        return
    }
    
    let updatedFileContents = fileContents.replacingOccurrences(of: oldString, with: newString)
    try? updatedFileContents.write(toFile: filePath, atomically: true, encoding: .utf8)
}
