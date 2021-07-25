//
//  RestClient+APIDefinition.swift
//  
//
//  Created by Bill Gestrich on 7/19/21.
//

import Foundation

public enum MethodType {
    case Get
    case Post
}

public protocol APIDefinition {
    var method: MethodType { get }
    var path: String { get }
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

    public let method: MethodType
    public let path: String
    private let convertJSONData: (Data) throws -> Out
    
    //typealias In = In
    //typealias Out = Out
    
    public init<Definition: APIDefinition>(wrappedDefinition: Definition) where Definition.Out == Out, Definition.In == In {
        self.convertJSONData = wrappedDefinition.convertJSONData
        self.method = wrappedDefinition.method
        self.path = wrappedDefinition.path
    }
    
    public func convertJSONData(_ data: Data) throws -> Out {
        return try convertJSONData(data)
    }
}

extension RestClient {
    
    public func performAPIOperation<T: APIDefinition>(input: T.In, apiDef: T, completionBlock:@escaping ((T.Out) -> Void), errorBlock:(@escaping (Error) -> Void)){
        
        switch apiDef.method {
        case .Get:
            self.getData(relativeURL: apiDef.path) { data in
                do {
                    completionBlock(try apiDef.convertJSONData(data))
                } catch {
                    errorBlock(error)
                }
            } errorBlock: { error in
                errorBlock(error)
            }
        case .Post:
            self.peformJSONPost(relativeURL: apiDef.path, payload: input) { data in
                do {
                    completionBlock(try apiDef.convertJSONData(data))
                } catch {
                    errorBlock(error)
                }
            } errorBlock: { error in
                errorBlock(error)
            }
        }
    }
}
