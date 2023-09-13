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

// MARK: Shell
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

public func safeShell(arguments: [String] = []) -> (stringResult: String? , code:Int32) {
    var env = ProcessInfo.processInfo.environment
    var path = env["PATH"]! as String

    if let pathString = shellCheck() {
        path = pathString + ":" + path
    } else {
        print("Unable to fetch users path")
        return ("Error fetching users path", 1)
    }
    let task = Process()
    env["PATH"] = path
    task.environment = env
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

public func shellCheck() -> String? {
    // Fetching users current shell
    let env = ProcessInfo.processInfo.environment
    let shellPath = env["SHELL"]!

    // Fetching users full path
    let pathProcess = Process()
    pathProcess.launchPath = "/usr/bin/env"
    pathProcess.arguments = ["\(shellPath)","-c","eval $(/usr/libexec/path_helper -s) ; echo $PATH"]
    let pipeShell = Pipe()
    pathProcess.standardOutput = pipeShell
    pathProcess.standardError = pipeShell
    pathProcess.launch()
    pathProcess.waitUntilExit()
    let pathData = pipeShell.fileHandleForReading.readDataToEndOfFile()
    guard let pathOutput: String = NSString(data: pathData, encoding: String.Encoding.utf8.rawValue) as String? else {
        print("Unable to build shell path")
        return nil
    }
    let cleanPathOutput = pathOutput.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
    return cleanPathOutput
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


//MARK: Text Input

public func promptForAction(title: String = "Select Option", actions: [CommandLineAction]) throws {
    let selection = promptForSelection(title: title, displayOneBasedIndex: true, options: actions.map({
        var option = $0.name
        if let abbreviation = $0.abbreviation {
            option = "\(option) (-\(abbreviation))"
        }
        return option
    }))
    try actions[selection].action()
}

public func promptForSelection(title: String, displayOneBasedIndex: Bool = false, options: [String]) -> Int {
    print("\n\(title)")
    
    var optionsString = ""
    var x = 0
    for option in options {
        option.withCString { //Using option string for C-String causes errors on Linux
            let indexDisplay = displayOneBasedIndex ? x + 1 : x
            optionsString = optionsString.appendingFormat("\n%u:  %s", indexDisplay, $0)
        }
        x += 1
    }
    
    print(optionsString)
    
    var toRet = -1
    repeat {
        let promptString = "\nEnter selection: "
        print(promptString, separator:" ", terminator:"")
        let userInput = readLine()
        guard let userInput = userInput, let intInput = Int(userInput) else {
            printError("Invalid Input: Expected a number")
            continue
        }
        
        let adjustedIndex = displayOneBasedIndex ? intInput - 1 : intInput
        
        guard adjustedIndex >= 0, adjustedIndex < options.count else {
            printError("Input out of range")
            continue
        }
            
        toRet = adjustedIndex
    } while toRet == -1

    return toRet
}

public func promptForText(title inputTitle: String, defaultText: String? = nil) -> String {
    var outputTitle = inputTitle
    outputTitle = outputTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    
    //Remove ending delimeter (: or ?) so we can add our default input if needed.
    var trailingDelimeter = ":" //Default
    if outputTitle.hasSuffix(":") {
        let _ = outputTitle.popLast()
    } else if outputTitle.hasSuffix("?") {
        let _ = outputTitle.popLast()
        trailingDelimeter = "?"
    }
    if let defaultText = defaultText {
        outputTitle = defaultText.count > 0 ? outputTitle + " [\(defaultText)]": outputTitle
    }
    outputTitle += "\(trailingDelimeter) "
    
    while true == true {
        
        print(outputTitle, separator:" ", terminator:"")
        if let response = readLine(), response.isEmpty == false {
            return response
        } else if let defaultText = defaultText {
            return defaultText
        } else {
            printError("No input")
        }
    }
}

public func promptForYesNo(question: String) -> Bool {
    while true {
        let input = promptForText(title: "\(question) y/n: ")
        if ["y", "yes"].contains(input.lowercased()) {
            return true
        } else if ["n", "no"].contains(input.lowercased()) {
            return false
        } else {
            printError("Invalid input \(input)")
        }
    }
}


//MARK: Logging

public func printStep(_ message: String){
    print("")
    let circleSymbol: String = "\u{25EF}"
    print(circleSymbol + " " + message)
}

public func printSuccess(_ message: String) {
    print("")
    let checkmarkSymbol: String = "\u{2705}"
    print(checkmarkSymbol + " " + message)
    print("")
}

public func printError(_ message: String) {
    print("")
    let errorSymbol: String = "\u{274C}"
    print(errorSymbol + " " + message)
    print("")
}
