//
//  SearchVCCellModel.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class SearchVCCellModel {

    let imageURL: String
    private weak var cache: ImageCache?
    let photo: Photo

    init(photo: Photo, imageCache: ImageCache) {
        self.imageURL = photo.thumbnailURL()
        self.photo = photo
        self.cache = imageCache
    }

    func getImage(idx: Int, completion: @escaping (_ image: UIImage?, _ url: String)->()) {
        cache?.getImage(idx: idx, urlString: imageURL, completion: { [weak self] (image, error, loadedURL) in
            if self == nil {
                print("=== no model")
                return
            }
            guard loadedURL == self!.imageURL else { return }
            completion(image, self!.imageURL)
        })
    }

    func cancelImageLoading(idx: Int) {
        cache?.cancelLoading(idx: idx, imageURL: imageURL)
    }
}
