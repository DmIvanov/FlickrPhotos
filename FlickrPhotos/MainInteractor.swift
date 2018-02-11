//
//  MainInteractor.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

/*
 Main business logic unit responsible for switching UI-scenes, storing and sharing global services
 */
class MainInteractor {

    // MARK: - Properties
    private weak var window: UIWindow?
    private let dataService: DataService
    private let vcFactory: ViewControllerFactory

    // MARK: - Lyfecycle
    init(mainWindow: UIWindow?, parameters: MainInteractorInitParameters? = nil) {
        window = mainWindow
        if let params = parameters {
            dataService = params.dataService
            vcFactory = params.viewControllerFactory
        } else {
            dataService = DataService()
            vcFactory = ViewControllerFactory()
        }
    }


    // MARK: - Public
    func appDidLaunched(options: [UIApplicationLaunchOptionsKey: Any]?) {
        goToSearchScreen()
        window?.makeKeyAndVisible()
    }


    // MARK: - Private
    private func goToSearchScreen() {
        let searchVC = vcFactory.searchVC()
        searchVC.setDataService(ds: dataService)
        let nc = UINavigationController(rootViewController: searchVC)
        window?.rootViewController = nc
    }
}


struct MainInteractorInitParameters {
    let dataService: DataService
    let viewControllerFactory: ViewControllerFactory
}
