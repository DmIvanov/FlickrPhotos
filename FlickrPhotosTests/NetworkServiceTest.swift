//
//  NetworkServiceTest.swift
//  FlickrPhotosTests
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import XCTest

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
        let exp = expectation(description: "NetworkServiceTest.testLoadPhotos")
        let methodToCompare = APIMethod.photosSearch
        serviceToTest.loadPhotos(query: query, page: page) { (photos, error) in
            let paramsToTest = self.apiClientMock.params
            XCTAssertNotNil(paramsToTest)
            self.checkParams(paramsToTest: paramsToTest!, paramsToCompare: self.serviceToTest.generalURLParams)
            self.checkParams(paramsToTest: paramsToTest!, key: self.serviceToTest.urlParamsMethodKey, value: methodToCompare.rawValue)
            self.checkParams(paramsToTest: paramsToTest!, key: self.serviceToTest.urlParamsSafeSearchKey, value: self.serviceToTest.urlParamsSafeSearchValue)
            self.checkParams(paramsToTest: paramsToTest!, key: self.serviceToTest.urlParamsPageKey, value: "\(page)")
            self.checkParams(paramsToTest: paramsToTest!, key: self.serviceToTest.urlParamsQueryKey, value: query)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testLoadPhotos_checkParser() {
        let query = "query"
        let page: UInt = 13
        let exp = expectation(description: "NetworkServiceTest.testLoadPhotos_checkParser")
        let methodToCompare = APIMethod.photosSearch
        apiClientMock.data = Data()
        serviceToTest.loadPhotos(query: query, page: page) { (photos, error) in
            XCTAssertTrue(self.parserMock.parseResponseCalled)
            XCTAssertNotNil(self.parserMock.method)
            XCTAssertEqual(self.parserMock.method!, methodToCompare)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testLoadPhotos_checkParser_nothingToParse() {
        let query = "query"
        let page: UInt = 13
        let exp = expectation(description: "NetworkServiceTest.testLoadPhotos_checkParser")
        serviceToTest.loadPhotos(query: query, page: page) { (photos, error) in
            XCTAssertFalse(self.parserMock.parseResponseCalled)
            XCTAssertNil(self.parserMock.method)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testLoadPhotos_checkEmptyQuery() {
        let query = ""
        let methodToCompare = APIMethod.photosGet
        let exp = expectation(description: "NetworkServiceTest.testLoadPhotos_checkEmptyQuery")
        serviceToTest.loadPhotos(query: query, page: 0) { (photos, error) in
            let paramsToTest = self.apiClientMock.params
            XCTAssertNotNil(paramsToTest)
            self.checkParams(paramsToTest: paramsToTest!, key: self.serviceToTest.urlParamsMethodKey, value: methodToCompare.rawValue)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
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

    var parseResponseCalled = false
    var method: APIMethod?

    override func parseResponse(method: APIMethod, data: Data, completion: (Any?, Error?) -> ()) {
        parseResponseCalled = true
        self.method = method
        completion(nil, nil)
    }
}


class APIClientMock: APIClient {

    var params: [String: String]?
    var url: String?
    var sendRequestCalled = false

    var data: Data?
    var response: URLResponse?
    var error: Error?

    override func sendRequest(url: String, params: [String: String], completion: @escaping RequestCompletion) {
        sendRequestCalled = true
        self.params = params
        self.url = url
        completion(data, response, error)
    }
}
