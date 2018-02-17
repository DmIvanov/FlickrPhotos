//
//  APIResponseParser.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 09/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import Foundation
import Promises

class APIResponseParser {

    // APIMethod.photosGet
    func processGetPhotosResponse(responseData: Data) -> Promise<[Photo]> {
        return Promise {
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(PhotosGetResponse.self, from: responseData)
            return responseObject.photos.photo
        }
    }

    // APIMethod.photosSearch
    func processSearchPhotoResponse(responseData: Data) -> Promise<[Photo]> {
        return Promise {
            let decoder = JSONDecoder()
            let responseObject = try decoder.decode(PhotosSearchResponse.self, from: responseData)
            return responseObject.photos.photo
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
