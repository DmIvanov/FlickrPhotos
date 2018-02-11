//
//  DataService.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

/*
 Class responsible for storing/retrieving persistent data for the app
 */
class DataService: NSObject {

    // MARK: - Properties
    static let dsPhotosUpdateSucceededNotification = NSNotification.Name(rawValue: "dsPhotosUpdateSucceededNotification")
    static let dsPhotosUpdateFailedNotification = NSNotification.Name(rawValue: "dsPhotosUpdateFailedNotification")

    private let networkService: NetworkService
    private let notificationService: NotificationServiceProtocol
    private(set) var photos = [Photo]()


    // MARK: - Lifecycle
    init(parameters: DataServiceInitParameters? = nil) {
        if let params = parameters {
            self.networkService = params.networkService
            self.notificationService = params.notificationService
        } else {
            self.networkService = NetworkService()
            self.notificationService = NotificationCenter.default
        }
    }


    // MARK: - Public
    func loadPhotos(query: String, page: UInt) {
        networkService.loadPhotos(query: query, page: page) { (apiPhotos, error) in
            if (error != nil || apiPhotos == nil) {
                DispatchQueue.main.async {
                    self.notificationService.post(name: DataService.dsPhotosUpdateFailedNotification, object: nil)
                }
            } else {
                self.photos = self.photos + apiPhotos!
                DispatchQueue.main.async {
                    self.notificationService.post(name: DataService.dsPhotosUpdateSucceededNotification, object: nil)
                }
            }
        }
    }

    func resetPhotos() {
        photos = [Photo]()
    }
}


struct DataServiceInitParameters {
    let networkService: NetworkService
    let notificationService: NotificationServiceProtocol
}


protocol NotificationServiceProtocol {
    func post(name aName: NSNotification.Name, object anObject: Any?)
}


extension NotificationCenter: NotificationServiceProtocol {}
