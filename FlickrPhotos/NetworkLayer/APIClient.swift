//
//  APIClient.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 09/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import Foundation
import Promises

typealias RequestCompletion = (Data?, URLResponse?, Error?) -> ()

/*
 Class-adapter responsible for wrapping current implementation
 of networking itself (URLSession, AFNetworking, Alamofire...)
 */
class APIClient {

    // MARK: - Properties
    private let session: URLSessionProtocol!

    // MARK: - Lyfecycle
    init(parameters: APIClientInitParameters? = nil) {
        if let params = parameters {
            self.session = params.session
        } else {
            self.session = URLSession.shared
        }
    }


    // MARK: - Public
    func sendRequest(url: String, params: [String: String]) -> Promise<(Data?, URLResponse?)> {
        return Promise { fulfill, reject in
            var components = URLComponents(string: url)!
            components.queryItems = params.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            let request = URLRequest(url: components.url!)
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil { reject(error!) }
                else { fulfill((data, response)) }
            })
            task.resume()
        }
    }
}


protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
}

struct APIClientInitParameters {
    let session: URLSessionProtocol
}


extension URLSession: URLSessionProtocol {}
