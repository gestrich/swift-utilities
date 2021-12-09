//
//  CommandLinePromptAction.swift
//  
//
//  Created by Bill Gestrich on 12/8/21.
//

import Foundation

public struct CommandLinePromptAction {
    public let name: String
    public let action: () throws -> Void
    
    public init(name: String, action: @escaping () throws -> Void) {
        self.name = name
        self.action = action
    }
    
}
