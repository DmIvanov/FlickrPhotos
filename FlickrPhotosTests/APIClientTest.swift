//
//  APIClientTest.swift
//  FlickrPhotosTests
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import XCTest
@testable import Promises

class APIClientTest: XCTestCase {

    var apiClientToTest: APIClient!

    var sessionMock: URLSessionMock!
    var taskMock: URLSessionDataTaskMock!
    var completion: RequestCompletion!

    override func setUp() {
        super.setUp()
        taskMock = URLSessionDataTaskMock()
        completion = { (data, response, error) -> () in }
        sessionMock = URLSessionMock(task: taskMock)
        let params = APIClientInitParameters(session: sessionMock)
        apiClientToTest = APIClient(parameters: params)
    }

    func testSendRequest() {
        let url = "url_string"
        let key1 = "key1"
        let val1 = "val1"
        let key2 = "key2"
        let val2 = "val2"
        let params: [String : String] = [
            key1 : val1,
            key2 : val2
        ]
        let result = apiClientToTest.sendRequest(url: url, params: params)
        XCTAssertTrue(result.isPending)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(result.isFulfilled)
        XCTAssertTrue(self.taskMock.resumeCalled)
        let request = self.sessionMock.request
        XCTAssertNotNil(request)
        let urlToCheck = request!.url
        XCTAssertNotNil(urlToCheck)
        let validUrl =
            (urlToCheck!.absoluteString == "\(url)?\(key1)=\(val1)&\(key2)=\(val2)") ||
                (urlToCheck!.absoluteString == "\(url)?\(key2)=\(val2)&\(key1)=\(val1)")
        XCTAssertTrue(validUrl)
    }
}


class URLSessionMock: URLSessionProtocol {

    var request: URLRequest?
    let task: URLSessionDataTaskMock

    init(task: URLSessionDataTaskMock) {
        self.task = task
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        self.request = request
        task.completion = completionHandler
        return task
    }
}


class URLSessionDataTaskMock: URLSessionDataTask {

    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    var _data: Data?
    var _response: URLResponse?
    var _error: NSError?

    var resumeCalled = false

    override func resume() {
        resumeCalled = true
        completion?(_data, _response, _error)
    }
}
