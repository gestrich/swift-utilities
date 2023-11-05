//
//  CommandLineAction.swift
//  
//
//  Created by Bill Gestrich on 12/8/21.
//

import Foundation

public struct CommandLineAction {
    public let name: String
    public let action: () async throws -> Void
    
    public init(actionName: String, action: @escaping () async throws -> Void) {
        self.name = actionName
        self.action = action
    }
    
}
