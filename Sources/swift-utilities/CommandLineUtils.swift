//
//  CommandLineUtils.swift
//  FFIOSTools
//
//  Created by Bill Gestrich on 10/14/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public func replaceProcess(program: String, arguments: [String]) {
    
    //Leading aray with "" to hack around issue where
    //first argument seems ignored by execv
    let argumentsWithEmptyEntry = [""] + arguments
    let cargs = argumentsWithEmptyEntry.map { strdup($0) } + [nil]
    
    execv(program, cargs)
    
}


public func shell(arguments: [String] = []) -> (stringResult: String? , code:Int32) {
    let task = Process()
    task.launchPath = "/usr/bin/env" 
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}


public func getProgram(commandLineArgs: [String]) -> String {
    
    var program = ""
    if commandLineArgs.count >= 2 {
        program = commandLineArgs[1]
    }
    
    return program
}

public func getProgramArguments(commandLineArgs: [String]) -> [String] {
    return Array(CommandLine.arguments[2..<CommandLine.arguments.count])
}

public func getEnvironmentVariable(key: String) -> String? {
    let keySeparator = "="
    let configurationPath = NSHomeDirectory().appending("/.fftools")
    guard let fileString = try? String(contentsOfFile: configurationPath) else {
        return nil
    }

    let allLines = fileString.components(separatedBy: .newlines)
    for line in allLines {
        let split = line.components(separatedBy: keySeparator)
        if split.count < 2 {
            continue
        }
        
        let thisKey = split[0]
        if key == thisKey {
            return line.getPartAfter(toSearch: keySeparator)
        }
    }
    
    return nil
}



public func promptForSelection(title: String, options: [String]) -> Int {
    print("\n\(title)")
    
    var promptString = ""
    var x = 0
    for option in options {
        promptString = promptString.appendingFormat("\n%u:  %@", x, option)
        x += 1
    }
    
    promptString = promptString.appendingFormat("\n\nEnter selection: ")
    print(promptString, separator:" ", terminator:"") 
    let response = readLine()
    return Int(response!)!
}

public func promptForText(title: String) -> String {
    print(title, separator:" ", terminator:"") 
    let response = readLine()
    return response!
}

