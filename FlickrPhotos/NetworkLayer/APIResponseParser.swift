//
//  APIResponseParser.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 09/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class APIResponseParser {

    func parseResponse(method: APIMethod, data: Data, completion: (Any?, Error?) -> ()) {
        switch method {
        case .photosGet:
            processGetPhotosResponse(responseData: data, completion: completion)
        case .photosSearch:
            processSearchPhotoResponse(responseData: data, completion: completion)
        }
    }

    // APIMethod.photosGet
    private func processGetPhotosResponse(responseData: Data, completion: ([Photo]?, Error?) -> ()) {
        do {
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(PhotosGetResponse.self, from: responseData)
            completion(responseObject.photos.photo, nil)
        } catch {
            print(error)
            completion(nil, error)
        }
    }

    // APIMethod.photosSearch
    private func processSearchPhotoResponse(responseData: Data, completion: ([Photo]?, Error?) -> ()) {
        do {
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(PhotosSearchResponse.self, from: responseData)
            completion(responseObject.photos.photo, nil)
        } catch {
            print(error)
            completion(nil, error)
        }
    }
}

struct PhotosGetResponse: Codable {
    struct Photos: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: Int
        let photo: [Photo]
    }
    let stat: String
    let photos: Photos
}

struct PhotosSearchResponse: Codable {
    struct Photos: Codable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        let photo: [Photo]
    }
    let stat: String
    let photos: Photos
}
