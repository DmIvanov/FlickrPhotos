//
//  SearchVCCellModel.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

struct SearchVCCellModel {

    let imageURL: String
    private weak var cache: ImageCache?

    init(photo: Photo, imageCache: ImageCache) {
        imageURL = "http://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        self.cache = imageCache
    }

    func getImage(completion: @escaping (_ image: UIImage?, _ url: String)->()) {
        cache?.getImage(urlString: imageURL, completion: completion)
    }
}
