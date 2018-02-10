//
//  ImageManager.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class ImageCache: NSObject {

    // MARK: - Properties
    private let id: String
    private let maxImagesInCache: UInt
    private let cacheChangeLock: DispatchQueue

    private var imageCache = [String: UIImage]()
    private var orderedIds = [String]()

    // MARK: - Lifecycle
    init(id: String, capacity: UInt) {
        self.id = id
        self.maxImagesInCache = capacity
        self.cacheChangeLock = DispatchQueue(label: "com.flickrPhotos.cacheChange.\(id)")
    }

    // MARK: - Public
    func getImage(urlString: String, completion: @escaping (_ image: UIImage?, _ url: String)->()) {
        DispatchQueue.global().async {
            if let cachedImage = self.cachedImageForURL(urlString) {
                DispatchQueue.main.async() {
                    completion(cachedImage, urlString)
                }
            } else if let url = URL(string: urlString) {
                do {
                    let data = try Data(contentsOf: url)
                    guard let image = UIImage(data: data) else {
                        completion(nil, urlString)
                        return
                    }
                    self.cacheImage(image: image, forURL: urlString)
                    DispatchQueue.main.async() {
                        completion(image, urlString)
                    }
                } catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async() {
                        completion(nil, urlString)
                    }
                }
            }
        }
    }

    // MARK: - Private
    private func cacheImage(image: UIImage, forURL url: String) {
        cacheChangeLock.async {
            if self.orderedIds.count > self.maxImagesInCache {
                let keyToRemove = self.orderedIds.removeFirst()
                self.imageCache.removeValue(forKey: keyToRemove)
            }
            self.orderedIds.append(url)
            self.imageCache[url] = image
        }
    }

    private func cachedImageForURL(_ url: String) -> UIImage? {
        var image: UIImage?
        cacheChangeLock.sync {
            image = imageCache[url]
        }
        return image
    }

    private func clearCache() {
        imageCache.removeAll()
    }
}
