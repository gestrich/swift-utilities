//
//  CommandLineAction.swift
//  
//
//  Created by Bill Gestrich on 12/8/21.
//

import Foundation

public struct CommandLineAction {
    public let name: String
    public let abbreviation: String?
    public let action: () throws -> Void
    
    public init(name: String, abbreviation: String? = nil, action: @escaping () throws -> Void) {
        self.name = name
        self.abbreviation = abbreviation
        self.action = action
    }
    
}
