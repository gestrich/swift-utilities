//
//  RestClient+APIDefinition.swift
//  
//
//  Created by Bill Gestrich on 7/19/21.
//

import Foundation

public typealias EmptyCodable = Dictionary<String,String>

public protocol RestAPI {
    var pathComponent: String { get }
    var parentPath: String { get }
    func path() -> String
    
    func formPath(parentPath: String, thisPathComponent: String) -> String
}

public extension RestAPI {
    
    func formPath(parentPath: String, thisPathComponent: String) -> String {
        return [parentPath, thisPathComponent].compactMap({$0.count > 0 ? $0 : nil}).joined(separator: "/")
    }
    func path() -> String {
        return self.formPath(parentPath: self.parentPath, thisPathComponent: self.pathComponent)
    }
}

public enum MethodType {
    case Get
    case Post
    case None
}

public protocol APIDefinition: RestAPI {
    var method: MethodType { get }
    associatedtype In: Codable
    associatedtype Out: Codable
    
    func convertJSONData(_ data: Data) throws -> Out
}

extension APIDefinition {
    public func convertJSONData(_ data: Data) throws -> Out {
        return try JSONDecoder().decode(Out.self, from: data)
    }
}


public struct AnyAPIDefinition<In: Codable, Out: Codable>: APIDefinition {
    public var pathComponent: String
    public var parentPath: String
    public let method: MethodType
    
    private let convertJSONData: (Data) throws -> Out
    
    //typealias In = In
    //typealias Out = Out
    
    public init<Definition: APIDefinition>(wrappedDefinition: Definition) where Definition.Out == Out, Definition.In == In {
        self.convertJSONData = wrappedDefinition.convertJSONData
        self.pathComponent = wrappedDefinition.pathComponent
        self.parentPath = wrappedDefinition.parentPath
        self.method = wrappedDefinition.method
    }
    
    public func convertJSONData(_ data: Data) throws -> Out {
        return try convertJSONData(data)
    }
}

extension RestClient {
    
    public func performAPIOperation<T: APIDefinition>(input: T.In, apiDef: T, completionBlock:@escaping ((T.Out) -> Void), errorBlock:(@escaping (Error) -> Void)){
        
        switch apiDef.method {
        case .Get:
            self.getData(relativeURL: apiDef.path()) { data in
                do {
                    completionBlock(try apiDef.convertJSONData(data))
                } catch {
                    errorBlock(error)
                }
            } errorBlock: { error in
                errorBlock(error)
            }
        case .Post:
            self.peformJSONPost(relativeURL: apiDef.path(), payload: input) { data in
                do {
                    completionBlock(try apiDef.convertJSONData(data))
                } catch {
                    errorBlock(error)
                }
            } errorBlock: { error in
                errorBlock(error)
            }
        case .None:
            fatalError("Can't perform None operation")
        }
    }
}
