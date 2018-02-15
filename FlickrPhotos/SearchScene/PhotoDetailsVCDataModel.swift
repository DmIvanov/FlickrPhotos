//
//  PhotoDetailsVCDataModel.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class PhotoDetailsVCDataModel: NSObject {

    let cache: ImageCache
    let photo: Photo

    init(imageCache: ImageCache, photo: Photo) {
        self.cache = imageCache
        self.photo = photo
    }

    func getImage(idx: Int, completion: @escaping (_ image: UIImage?)->()) {
        cache.getImage(urlString: photo.imageURL(), completion: { (image, error, loadedURL) in
            completion(image)
        })
    }

    func title() -> String? {
        return photo.title
    }

    func detailesText() -> String {
        return """
        \(photo.imageURL())
        """
    }
}
