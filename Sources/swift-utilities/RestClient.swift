//
//  RestClient.swift
//  FFIOSTools
//
//  Created by Bill Gestrich on 10/29/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

class RestClient: NSObject {
    
    let baseURL: String
    var headers: [String:String]?
    var auth : BasicAuth?
    
    init(baseURL: String){
        self.baseURL = baseURL
        super.init()
    }
    
    convenience init(baseURL: String, auth: BasicAuth){
        self.init(baseURL: baseURL)
        self.auth = auth
    }
    
    func jsonFor(relativeURL: String) -> NSDictionary {
        let urlString = baseURL.appending(relativeURL)
        return jsonFor(fullURL:urlString)
    }
    
    func jsonFor(fullURL: String) -> NSDictionary {
        var headersToSet = ["Content-Type":"application/json", "Accept":"application/json"]
        if let headers = self.headers {
            headersToSet += headers
        }
        let http = SimpleHttp(auth:self.auth, headers:headersToSet);
        let url = URL(string: fullURL)!
        let json = http.getJSON(url:url)
        
        return json        
    }

}
