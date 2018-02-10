//
//  APIClient.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 09/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import Foundation

typealias RequestCompletion = (Data?, URLResponse?, Error?) -> ()

class APIClient: NSObject {

    // MARK: - Properties
    private let apiURL = "https://api.flickr.com/services/rest/?"
    private let generalURLParams: [String: String] = [
        "api_key" : "3e7cc266ae2b0e0d78e279ce8e361736",
        "format" : "json",
        "nojsoncallback" : "1"
    ]
    private var session: URLSessionProtocol!


    // MARK: - Lyfecycle
    init(session sessionToSet: URLSessionProtocol? = nil) {
        super.init()
        if (sessionToSet == nil) {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        } else {
            self.session = sessionToSet
        }
    }


    // MARK: - Public
    func loadPhotos(query: String, page: UInt, completion: @escaping ([Photo]?, Error?) -> ()) {
        let params: [String: String] = [
            "safe_search" : "1",
            "page" : "\(page)",
            "text" : query
        ]

        // Flickr API doesn't allow to use `photosSearch` method without any query
        let apiMethod = (query.count > 0) ? APIMethod.photosSearch : APIMethod.photosGet

        sendRequest(method: apiMethod, requestParams: params) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
//            let response = try? JSONSerialization.jsonObject(
//                with: data,
//                options: JSONSerialization.ReadingOptions.mutableContainers
//            )
//            print(response)

            APIResponseParser.parseResponse(method: apiMethod, data: data, completion: { (responseObj, error) in
                if error != nil {
                    completion(nil, error)
                } else if let photos = responseObj as? [Photo] {
                    completion(photos, nil)
                } else {
                    completion(nil, APIError.WrongJSONFormat)
                }
            })
        }
    }


    // MARK: - Private
    private func sendRequest(method: APIMethod, requestParams: [String: String], completion: @escaping RequestCompletion) {
        var params = generalURLParams
        requestParams.forEach { (key, value) in
            params[key] = value
        }
        params["method"] = method.rawValue
        var components = URLComponents(string: apiURL)!
        components.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        print("API REQUEST: " + "\(params)")
        //print("API REQUEST: " + "\(components.url!.absoluteString)")
        let request = URLRequest(url: components.url!)
        let task = session.dataTask(
            with: request,
            completionHandler: completion
        )
        task.resume()
    }
}


protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
}


extension URLSession: URLSessionProtocol {}


extension APIClient: URLSessionDelegate {}


enum APIMethod: String {
    case photosGet = "flickr.photos.getRecent"
    case photosSearch = "flickr.photos.search"
}


enum APIError: Error {
    case RequestIsInProgress
    case WrongJSONFormat
}
