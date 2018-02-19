//
//  DataServiceTest.swift
//  FlickrPhotosTests
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import XCTest
@testable import Promises

class DataServiceTest: XCTestCase {

    var serviceToTest: DataService!

    var networkServiceMock: NetworkServiceMock!
    var notificationServiceMock: NotificationServiceMock!

    let query = "query"
    let page: UInt = 13

    override func setUp() {
        networkServiceMock = NetworkServiceMock()
        notificationServiceMock = NotificationServiceMock()
        let params = DataServiceInitParameters(networkService: networkServiceMock, notificationService: notificationServiceMock)
        serviceToTest = DataService(parameters: params)
        super.setUp()
    }

    func testLoadPhotos_networkService() {
        serviceToTest.loadPhotos(query: query, page: page)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(networkServiceMock.loadPhotosCalled)
        XCTAssertNotNil(networkServiceMock.query)
        XCTAssertNotNil(networkServiceMock.page)
        XCTAssertEqual(networkServiceMock.query!, query)
        XCTAssertEqual(networkServiceMock.page!, page)
    }

    func testLoadPhotos_notificationService_success() {
        networkServiceMock.photos = [Photo]()
        serviceToTest.loadPhotos(query: query, page: page)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(self.notificationServiceMock.postCalled)
        XCTAssertEqual(self.notificationServiceMock.name, DataService.dsPhotosUpdateSucceededNotification)
    }

    func testLoadPhotos_notificationService_failure() {
        networkServiceMock.error = NSError(domain: "", code: 0, userInfo: nil)
        serviceToTest.loadPhotos(query: query, page: page)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(self.notificationServiceMock.postCalled)
        XCTAssertEqual(self.notificationServiceMock.name, DataService.dsPhotosUpdateFailedNotification)
    }

    func testLoadPhotos_addingPhotos() {
        networkServiceMock.photos = [Photo(), Photo()]
        serviceToTest.loadPhotos(query: query, page: page)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertEqual(serviceToTest.photos.count, 2)
    }

    func testLoadPhotos_networkError() {
        networkServiceMock.photos = [Photo(), Photo()]
        networkServiceMock.error = APIError.WrongJSONFormat
        serviceToTest.loadPhotos(query: query, page: page)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertEqual(serviceToTest.photos.count, 0)
    }
}


class NotificationServiceMock: NotificationServiceProtocol {

    var postCalled = false
    var name: NSNotification.Name?
    var object: Any?

    func post(name aName: NSNotification.Name, object anObject: Any?) {
        self.postCalled = true
        self.name = aName
        self.object = anObject
    }
}


class NetworkServiceMock: NetworkService {

    var loadPhotosCalled = false
    var query: String?
    var page: UInt?

    var photos = [Photo]()
    var error: Error?

    override func loadPhotos(query: String, page: UInt) -> Promise<[Photo]> {
        NSLog("load calledq")
        self.loadPhotosCalled = true
        self.query = query
        self.page = page
        return Promise { fulfill, reject in
            NSLog("load promise calledq")
            if self.error != nil {
                reject(self.error!)
            } else  {
                fulfill(self.photos)
            }
        }
    }
}


extension Photo {
    init() {
        self.farm = 0
        self.id = ""
        self.server = ""
        self.secret = ""
        self.title = nil
    }
}
