//
//  APINotesOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 20.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

private var URLSessionTaskOperationKVOContext = 0

enum NetworkMethod: String {
    case GET = "GET"
    case PUT = "PUT"
    case POST = "POST"
    case DELETE = "DELETE"
}

enum APINotesOperationError: Error {
    case saveTmpError
    case serverError
}

class APINotesOperation: AsyncOperation {
    let completeHandler: (Error?) -> Void
    let cacheFile: URL
    let method: NetworkMethod
    let apiRequestStatus: APIRequestStatus
    let note: Note?
    
    var task: URLSessionTask?
    
    fileprivate var observerRemoved = false
    fileprivate let stateLock = NSLock()
    
    init(method: NetworkMethod, note: Note? = nil, cacheFile: URL, apiRequestStatus: APIRequestStatus, completeHandler: @escaping (Error?) -> Void) {
        self.completeHandler = completeHandler
        self.cacheFile = cacheFile
        self.apiRequestStatus = apiRequestStatus
        self.method = method
        self.note = note
        
        super.init()
        
        var request: URLRequest
        switch method {
        case .GET:
            request = APIManager.shared.getNotesRequest()
        case .PUT:
            request = APIManager.shared.editNoteRequest(json: note?.json ?? ["": ""])
        case .DELETE:
            request = APIManager.shared.deleteNoteOperation(json: note?.json ?? ["": ""])
        case .POST:
            request = APIManager.shared.addNoteRequest(json: note?.json ?? ["": ""])
        }

        self.task = URLSession.shared.dataTask(with: request) { data, response, err in
            print("Network current try: \(apiRequestStatus.networkTries)")
            self.apiRequestStatus.networkTries += 1
            self.apiRequestStatus.resetState()
            self.requestFinished(data: data, response: response, error: err)
        }
    }
    
    func requestFinished(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                print(json as Any)
                do {
                    try FileManager.default.removeItem(at: cacheFile)
                }
                catch { }
                
                do {
                    try data.write(to: cacheFile, options: [])
                }
                catch {
                    print("Data write error \(error)")
                    apiRequestStatus.state = .Failed
                    apiRequestStatus.add(error: APINotesOperationError.saveTmpError)
                }
                apiRequestStatus.state = .Sucsess
            } else {
                print(response as Any, json as Any)
                apiRequestStatus.state = .Failed
                apiRequestStatus.add(error: APINotesOperationError.serverError)
            }
        } else {
            apiRequestStatus.state = .Failed
            apiRequestStatus.add(error: APINotesOperationError.serverError)
        }
        completeHandler(error)
        finish()
    }
    
    override func didCancel() {
        task?.cancel()
        finish()
    }
    
    override func main() {
        //task?.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(), context: &URLSessionTaskOperationKVOContext)
        if apiRequestStatus.state == .Sucsess {
            completeHandler(nil)
            finish()
        } else {
            task?.resume()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &URLSessionTaskOperationKVOContext else { return }
        guard let object = object else { return }
        
        stateLock.withCriticalScope {
            guard let task = task else { return }
            if object as AnyObject === task && keyPath == "state" && !observerRemoved {
                switch task.state {
                case .completed:
                    finish()
                    fallthrough
                case .canceling:
                    observerRemoved = true
                    task.removeObserver(self, forKeyPath: "state")
                default:
                    return
                }
            }
        }
    }
}
