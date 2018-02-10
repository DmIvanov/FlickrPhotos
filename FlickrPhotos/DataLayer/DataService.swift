//
//  DataService.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class DataService: NSObject {

    static let dsPhotosUpdateSucceededNotification = NSNotification.Name(rawValue: "dsPhotosUpdateSucceededNotification")
    static let dsPhotosUpdateFailedNotification = NSNotification.Name(rawValue: "dsPhotosUpdateFailedNotification")

    private let apiClient = APIClient()
    private(set) var photos = [Photo]()

    func loadPhotos(query: String, page: UInt) {
        apiClient.loadPhotos(query: query, page: page) { (apiPhotos, error) in
            if (error != nil || apiPhotos == nil) {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: DataService.dsPhotosUpdateFailedNotification, object: nil)
                }
            } else {
                self.photos = self.photos + apiPhotos!
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: DataService.dsPhotosUpdateSucceededNotification, object: nil)
                }
            }
        }
    }

    func resetPhotos() {
        photos = [Photo]()
    }
}
