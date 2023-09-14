//
//  CommandLineAction.swift
//  
//
//  Created by Bill Gestrich on 12/8/21.
//

import Foundation

public struct CommandLineAction {
    public let longName: String
    public let shortName: String?
    public let action: () throws -> Void
    
    public init(longName: String, shortName: String? = nil, action: @escaping () throws -> Void) {
        self.longName = longName
        self.shortName = shortName
        self.action = action
    }
    
}
