//
//  NetworkService.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

/*
 Class-facade for all the remote API interaction
 it is aware of all the details of Flickr API
 */
class NetworkService: NSObject {

    // MARK: - Properties
    let apiURL = "https://api.flickr.com/services/rest/?"
    let generalURLParams: [String: String] = [
        "api_key" : "3e7cc266ae2b0e0d78e279ce8e361736",
        "format" : "json",
        "nojsoncallback" : "1"
    ]
    let urlParamsSafeSearchKey = "safe_search"
    let urlParamsSafeSearchValue = "1"
    let urlParamsPageKey = "page"
    let urlParamsQueryKey = "text"
    let urlParamsMethodKey = "method"
    
    private let apiClient: APIClient
    private let parser: APIResponseParser


    // MARK: - Lyfecycle
    init(parameters: NetworkServiceInitParameters? = nil) {
        if let params = parameters {
            self.parser = params.parser
            self.apiClient = params.apiClient
        } else {
            self.parser = APIResponseParser()
            self.apiClient = APIClient()
        }
    }

    
    // MARK: - Public
    func loadPhotos(query: String, page: UInt, completion: @escaping ([Photo]?, Error?) -> ()) {
        let params: [String: String] = [
            urlParamsSafeSearchKey : urlParamsSafeSearchValue,
            urlParamsPageKey : "\(page)",
            urlParamsQueryKey : query
        ]

        // Flickr API doesn't allow to use `photosSearch` method without any query
        let apiMethod = (query.count > 0) ? APIMethod.photosSearch : APIMethod.photosGet

        sendRequest(method: apiMethod, requestParams: params) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            self.parser.parseResponse(method: apiMethod, data: data, completion: { (responseObj, error) in
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
        params[urlParamsMethodKey] = method.rawValue
        apiClient.sendRequest(url: apiURL, params: params, completion: completion)
    }
}


struct NetworkServiceInitParameters {
    let apiClient: APIClient
    let parser: APIResponseParser
}


enum APIMethod: String {
    case photosGet = "flickr.photos.getRecent"
    case photosSearch = "flickr.photos.search"
}


enum APIError: Error {
    case RequestIsInProgress
    case WrongJSONFormat
}
