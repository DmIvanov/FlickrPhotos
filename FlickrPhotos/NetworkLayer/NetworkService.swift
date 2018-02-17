//
//  NetworkService.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit
import Promises

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

    func loadPhotos(query: String, page: UInt) -> Promise<[Photo]> {
        let params: [String: String] = [
            self.urlParamsSafeSearchKey : self.urlParamsSafeSearchValue,
            self.urlParamsPageKey : "\(page)",
            self.urlParamsQueryKey : query
        ]

        // Flickr API doesn't allow to use `photosSearch` method without any query
        if query.count > 0 {
            return sendRequest(method: APIMethod.photosSearch, requestParams: params).then(parser.processSearchPhotoResponse)
        } else {
            return sendRequest(method: APIMethod.photosGet, requestParams: params).then(parser.processGetPhotosResponse)
        }
    }

    // MARK: - Private

    private func sendRequest(method: APIMethod, requestParams: [String: String]) -> Promise<Data> {
        var params = generalURLParams
        requestParams.forEach { (key, value) in
            params[key] = value
        }
        params[urlParamsMethodKey] = method.rawValue
        return apiClient.sendRequest(url: apiURL, params: params).then { (data, response) -> Promise<Data> in
            if data == nil {
                throw APIError.CorruptedResponse
            } else {
                return Promise(data!)
            }
        }
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
    case CorruptedResponse
}
