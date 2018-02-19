//
//  NetworkServiceTest.swift
//  FlickrPhotosTests
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import XCTest
@testable import Promises

class NetworkServiceTest: XCTestCase {

    var serviceToTest: NetworkService!

    var apiClientMock: APIClientMock!
    var parserMock: APIResponseParserMock!

    override func setUp() {
        super.setUp()
        apiClientMock = APIClientMock()
        parserMock = APIResponseParserMock()
        let params = NetworkServiceInitParameters(apiClient: apiClientMock, parser: parserMock)
        serviceToTest = NetworkService(parameters: params)
    }

    func testLoadPhotos_checkParams() {
        let query = "query"
        let page: UInt = 13
        let methodToCompare = APIMethod.photosSearch
        apiClientMock.data = Data()

        let result = serviceToTest.loadPhotos(query: query, page: page)

        XCTAssertTrue(result.isPending)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(result.isFulfilled)
        let paramsToTest = apiClientMock.params
        XCTAssertNotNil(paramsToTest)
        checkParams(paramsToTest: paramsToTest!, paramsToCompare: serviceToTest.generalURLParams)
        checkParams(paramsToTest: paramsToTest!, key: serviceToTest.urlParamsMethodKey, value: methodToCompare.rawValue)
        checkParams(paramsToTest: paramsToTest!, key: serviceToTest.urlParamsSafeSearchKey, value: serviceToTest.urlParamsSafeSearchValue)
        checkParams(paramsToTest: paramsToTest!, key: serviceToTest.urlParamsPageKey, value: "\(page)")
        checkParams(paramsToTest: paramsToTest!, key: serviceToTest.urlParamsQueryKey, value: query)
    }

    func testLoadPhotos_checkParser() {
        let query = "query"
        let page: UInt = 13
        apiClientMock.data = Data()

        let result = serviceToTest.loadPhotos(query: query, page: page)

        XCTAssertTrue(result.isPending)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(result.isFulfilled)
        XCTAssertTrue(parserMock.processSearchPhotoCalled)
        XCTAssertFalse(parserMock.processGetPhotoCalled)
        XCTAssertEqual(apiClientMock.data, parserMock.data)
    }

    func testLoadPhotos_checkParser_nothingToParse() {
        let query = "query"
        let page: UInt = 13

        let result = serviceToTest.loadPhotos(query: query, page: page)

        XCTAssertTrue(result.isPending)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(result.isRejected)
        XCTAssertFalse(parserMock.processSearchPhotoCalled)
        XCTAssertFalse(parserMock.processGetPhotoCalled)
        XCTAssertNil(parserMock.data)
    }

    func testLoadPhotos_checkEmptyQuery() {
        let query = ""
        let page: UInt = 0
        apiClientMock.data = Data()

        let result = serviceToTest.loadPhotos(query: query, page: page)

        XCTAssertTrue(result.isPending)
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertTrue(result.isFulfilled)
        let paramsToTest = apiClientMock.params
        XCTAssertNotNil(paramsToTest)
        XCTAssertTrue(parserMock.processGetPhotoCalled)
        XCTAssertFalse(parserMock.processSearchPhotoCalled)
        checkParams(paramsToTest: paramsToTest!, key: serviceToTest.urlParamsMethodKey, value: APIMethod.photosGet.rawValue)
    }


    // MARK: - Private
    private func checkParams(paramsToTest: [String: String], paramsToCompare: [String: String]) {
        for (k, v1) in paramsToCompare {
            let v2 = paramsToTest[k]
            XCTAssertNotNil(v2)
            XCTAssertEqual(v1, v2)
        }
    }

    private func checkParams(paramsToTest: [String: String], key: String, value: String) {
        let v = paramsToTest[key]
        XCTAssertNotNil(v)
        XCTAssertEqual(v, value)
    }
}


class APIResponseParserMock: APIResponseParser {

    var processSearchPhotoCalled = false
    var processGetPhotoCalled = false
    var data: Data?

    override func processSearchPhotoResponse(responseData: Data) -> Promise<[Photo]> {
        processSearchPhotoCalled = true
        data = responseData
        return Promise {
            return [Photo]()
        }
    }

    override func processGetPhotosResponse(responseData: Data) -> Promise<[Photo]> {
        processGetPhotoCalled = true
        data = responseData
        return Promise {
            return [Photo]()
        }
    }
}


class APIClientMock: APIClient {

    var params: [String: String]?
    var url: String?
    var sendRequestCalled = false

    var data: Data?
    var response: URLResponse?
    var error: Error?

    override func sendRequest(url: String, params: [String : String]) -> Promise<(Data?, URLResponse?)> {
        sendRequestCalled = true
        self.params = params
        self.url = url
        return Promise<(Data?, URLResponse?)> { fulfill, reject in
            if self.error == nil {
                fulfill((self.data, self.response))
            } else {
                reject(self.error!)
            }
        }
    }
}

