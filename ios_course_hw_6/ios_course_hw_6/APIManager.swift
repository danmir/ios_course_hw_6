//
//  APIManager.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 19.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

private let _sharedManager = APIManager()
//let accessToken = "NorthPole"

class APIManager {
    class var shared: APIManager {
        return _sharedManager
    }
    
    let scheme = "http"
    let host = "notes.mrdekk.ru"
    let maxRetriesCount = 3
    
    var accessToken: String {
        get {
            let defaults = UserDefaults.standard
            if let token = defaults.string(forKey: "token") {
                return token
            } else {
                return ""
            }
        }
    }
    
    init() {}
    
    func createURL(withPath path: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme;
        urlComponents.host = host;
        urlComponents.path = path;
        
        return urlComponents.url
    }
    
    func createRequest(withBody body: Data? = nil, method: String, url: URL?) -> URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func getNotesRequest() -> URLRequest {
        let url = createURL(withPath: "/notes")
        let request = createRequest(method: "GET", url: url)
        
        return request
    }
    
    func addNoteRequest(json: [String: Any]) -> URLRequest {
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = createURL(withPath: "/notes")
        let request = createRequest(withBody: jsonData, method: "POST", url: url)
        
        return request
    }
    
    func editNoteRequest(json: [String: Any]) -> URLRequest {
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let uid = json["uid"] as! String
        
        let url = createURL(withPath: "/notes/\(uid)")
        let request = createRequest(withBody: jsonData, method: "PUT", url: url)
        
        return request
    }
    
    func deleteNoteOperation(json: [String: Any]) -> URLRequest {
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let uid = json["uid"] as! String
        
        let url = createURL(withPath: "/notes/\(uid)")
        let request = createRequest(withBody: jsonData, method: "DELETE", url: url)
        
        return request
    }
}
