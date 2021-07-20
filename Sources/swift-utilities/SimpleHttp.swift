//
//  SimpleHttp.swift
//  swift-utilities
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct BasicAuth {
    let username : String
    let password : String
    
    public init(username : String, password: String){
        self.username = username
        self.password = password
    }
}


public class SimpleHttp: NSObject {
    
    var auth : BasicAuth?
    var headers: [String: String] = [String: String]()
    
    init(auth: BasicAuth?){
        self.auth = auth
        super.init()
    }
    
    convenience init(auth: BasicAuth?, headers: [String: String]){
        self.init(auth: auth)
        self.headers = headers
    }
    
    func getData(url: URL, completionBlock:(@escaping (Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        let request = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        
        var authHeaders = [String: String]()
        if let auth = self.auth {
            let userPasswordData = "\(auth.username):\(auth.password)".data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            let authString = "Basic \(base64EncodedCredential)"
            authHeaders["authorization"] = authString
        }
        authHeaders += self.headers
        config.httpAdditionalHeaders = authHeaders
        
        print("Curl = \(curlRequestWithURL(url:url.absoluteString, headers:authHeaders))")
        
        let session: URLSession = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                print("Error while trying to re-authenticate the user: \(error)")
                errorBlock(.serviceError(error)) //Error
            } else if let response = response as? HTTPURLResponse,
                300..<600 ~= response.statusCode {
                errorBlock(.statusCode(response.statusCode)) //Error
            } else if let data = data {
                completionBlock(data) //Success
            } else {
                errorBlock(.noData) //Error
            }
        })
        
        task.resume()
    }
    
    func peformJSONPost<T>(url: URL, payload: T, completionBlock:@escaping ((Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void))  where T : Encodable {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var authHeaders = [String: String]()
        if let auth = self.auth {
            let userPasswordData = "\(auth.username):\(auth.password)".data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            let authString = "Basic \(base64EncodedCredential)"
            authHeaders["authorization"] = authString
        }
        authHeaders += self.headers
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = authHeaders
        
        let data = try! JSONEncoder().encode(payload)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                errorBlock(.serviceError(error))
                return
            }
            
            guard let data = data else {
                errorBlock(.noData)
                return
            }
//
//            guard let response = response else {
//                errorBlock(self.genericError(errorInformation: "No response returned"))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                errorBlock(self.genericError(errorInformation: "Could not translate response to HTTPURLResponse: \(response.self)"))
//                return
//            }
//
//            guard let urlString = String(data: data, encoding: .utf8) else{
//                errorBlock(self.genericError(errorInformation: "No URL from Data"))
//                return
//            }
//
//            guard httpResponse.statusCode == 200 else {
//                errorBlock(self.genericError(errorInformation: "Status code \(httpResponse.statusCode) returned. Data: \(urlString)"))
//                return
//            }
//
            completionBlock(data)
        }
        task.resume()
    }
    
    func uploadFile(fileUrl: URL, destinationURL: URL, completionBlock:(@escaping (Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        
        let fileName = (fileUrl.path as NSString).lastPathComponent
        let fileData = FileManager.default.contents(atPath: fileUrl.path)!
        let parameterNameForFile = "file" //TODO: move out of here as this is jira api specific
        
        var urlRequest = URLRequest(url: destinationURL)
        urlRequest.httpMethod = "POST"
        
        let config = URLSessionConfiguration.default
        
        var headers = [String: String]()
        if let auth = self.auth {
            var authString = ""
            let userPasswordData = "\(auth.username):\(auth.password)".data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            authString = "Basic \(base64EncodedCredential)"
            headers["authorization"] = authString
        }
        
        headers += self.headers
        config.httpAdditionalHeaders = headers
        
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(parameterNameForFile)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        
        let contentType = "application/octet-stream"
        data.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let session: URLSession = URLSession(configuration: config, delegate: nil, delegateQueue: nil)

         let task = session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if let error = error {
                print("Error while trying to re-authenticate the user: \(error)")
                errorBlock(.serviceError(error)) //Error
            } else if let response = response as? HTTPURLResponse,
                300..<600 ~= response.statusCode {
                errorBlock(.statusCode(response.statusCode)) //Error
            } else if let data = responseData {
                completionBlock(data) //Success
            } else {
                errorBlock(.noData) //Error
            }
        })
        
        task.resume()
    }
    
}

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

func curlRequestWithURL (url: String, headers:Dictionary<String, String>) -> String {
    
    //Example output:
    //curl --header "Date: January 10, 2017 14:37:21" -L  <url>
    
    var toRet = "curl "
    
    if headers.count > 0 {
        for (headerKey, headerValue) in headers {
            toRet += "--header "
            toRet += " \"\(headerKey): \(headerValue)\" "
        }
        
        toRet += "-L "
        
        toRet += "\"\(url)\""
    }
    
    return toRet
}
