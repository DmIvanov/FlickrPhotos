//
//  MainInteractorTest.swift
//  FlickrPhotosTests
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import XCTest

class MainInteractorTest: XCTestCase {

    var interactorToTest: MainInteractor!

    var windowMock: WindowMock!
    var vcFactoryMock: ViewControllerFactoryMock!
    var dataServiceMock: DataServiceMock!
    var searchVCMock: SearchVCMock!

    override func setUp() {
        super.setUp()
        windowMock = WindowMock()
        dataServiceMock = DataServiceMock()
        vcFactoryMock = ViewControllerFactoryMock()
        searchVCMock = SearchVCMock()
        vcFactoryMock.searchViewController = searchVCMock
        let params = MainInteractorInitParameters(dataService: dataServiceMock, viewControllerFactory: vcFactoryMock)
        interactorToTest = MainInteractor(
            mainWindow: windowMock,
            parameters: params
        )
    }

    func testAppDidLaunched() {
        interactorToTest.appDidLaunched(options: nil)

        XCTAssertTrue(windowMock.makeKeyAndVisibleCalled)
        let rootVC = windowMock.rootViewController
        XCTAssertNotNil(rootVC)
        let rootNavigationController = rootVC as? UINavigationController
        XCTAssertNotNil(rootNavigationController)
        let vcInStack = rootNavigationController!.viewControllers.first as? SearchVCMock
        XCTAssertNotNil(vcInStack)
        XCTAssertEqual(vcInStack!, vcFactoryMock.searchViewController)
        XCTAssertNotNil(vcInStack!.dataService)
        XCTAssertEqual(vcInStack!.dataService!, dataServiceMock)
    }
    
}


class WindowMock: UIWindow {
    var makeKeyAndVisibleCalled = false
    override func makeKeyAndVisible() {
        makeKeyAndVisibleCalled = true
    }
}


class DataServiceMock: DataService {
    
}


class ViewControllerFactoryMock: ViewControllerFactory {
    var searchViewController: SearchVCMock?
    override func searchVC() -> SearchVC {
        return searchViewController!
    }
}


class SearchVCMock: SearchVC {
    var dataService: DataService?
    override func setDataService(ds: DataService) {
        dataService = ds
    }
}
