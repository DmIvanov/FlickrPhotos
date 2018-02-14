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
        queue.maxConcurrentOperationCount = 10
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
    func getImage(idx: Int, urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error?, _ url: String)->()) {
        //print("load image: \(idx)")
        if let cachedImage = self.cachedImageForURL(urlString) {
            DispatchQueue.main.async() {
                //print("  from cache: \(idx)")
                completion(cachedImage, nil, urlString)
            }
        } else {
            if let operation = operationsInProgress[urlString] {
                //print("  already in queue: \(idx)")
                return
            }
            let operation = ImageLoadingOperation(idx: idx, imageURL: urlString)
            operationsInProgress[urlString] = operation
            operation.completionBlock = { [weak self] in
                self?.operationsInProgress.removeValue(forKey: urlString)
                if let image = operation.image {
                    self?.cacheImage(image: image, forURL: urlString)
                }
                DispatchQueue.main.async() {
                    //print("  finished: \(idx) [\(self?.queue.operationCount) in queue]")
                    completion(operation.image, operation.error, urlString)
                }
            }
            queue.addOperation(operation)
        }
    }

    func cancelLoading(idx: Int, imageURL: String) {
        if let operation = operationsInProgress[imageURL] {
            operation.cancel()
            //print("canceled: \(idx) [\(queue.operationCount) in queue]")
        } else {
           // print("nothing to cancel: \(idx)")
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
