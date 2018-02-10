//
//  MainInteractor.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class MainInteractor {

    // MARK: - Properties
    private weak var window: UIWindow?
    fileprivate let dataService = DataService()

    // MARK: - Lyfecycle
    init(mainWindow: UIWindow?) {
        window = mainWindow
    }


    // MARK: - Public
    func appDidLaunched(options: [UIApplicationLaunchOptionsKey: Any]?) {
        goToSearchScreen()
        window?.makeKeyAndVisible()
    }


    // MARK: - Private
    private func goToSearchScreen() {
        let searchVC = ViewControllerFactory.searchVC()
        searchVC.setDataService(ds: dataService)
        let nc = UINavigationController(rootViewController: searchVC)
        window?.rootViewController = nc
    }
}
