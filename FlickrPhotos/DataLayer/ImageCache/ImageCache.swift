//
//  ImageManager.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class ImageCache {

    // MARK: - Properties
    private let id: String
    private let maxImagesInCache: UInt
    private let cacheChangeLock: DispatchQueue

    private var imageCache = [String: UIImage]()
    private var orderedIds = [String]()

    private var operationsInProgress = [String: ImageLoadingOperation]()
    private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 30
        return queue
    }()

    // MARK: - Lifecycle
    init(id: String, capacity: UInt) {
        self.id = id
        self.maxImagesInCache = capacity
        self.cacheChangeLock = DispatchQueue(label: "com.flickrPhotos.cacheChange.\(id)")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(memoryWarningReceived),
            name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
            object: nil
        )
    }

    // MARK: - Public
    func getImage(urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error?, _ url: String)->()) {
        if let cachedImage = self.cachedImageForURL(urlString) {
            DispatchQueue.main.async() {
                //print("  from cache: \(idx)")
                completion(cachedImage, nil, urlString)
            }
        } else {
            if let _ = operationsInProgress[urlString] {
                return
            }
            let operation = ImageLoadingOperation(imageURL: urlString)
            operationsInProgress[urlString] = operation
            operation.completionBlock = { [weak self] in
                self?.operationsInProgress.removeValue(forKey: urlString)
                if let image = operation.image {
                    self?.cacheImage(image: image, forURL: urlString)
                }
                DispatchQueue.main.async() {
                    completion(operation.image, operation.error, urlString)
                }
            }
            queue.addOperation(operation)
        }
    }

    func cancelLoading(imageURL: String) {
        if let operation = operationsInProgress[imageURL] {
            operation.cancel()
            operationsInProgress.removeValue(forKey: imageURL)
        } else {
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
        cacheChangeLock.sync {
            imageCache.removeAll()
            orderedIds.removeAll()
        }
    }

    @objc func memoryWarningReceived(notification: Notification) {
        clearCache()
    }
}
