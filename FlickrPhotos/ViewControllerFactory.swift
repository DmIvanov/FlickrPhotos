//
//  ViewControllerFactory.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class ViewControllerFactory: NSObject {

    // MARK: - Public
    func searchVC() -> SearchVC {
        return mainStoryboard().instantiateViewController(withIdentifier: String(describing: SearchVC.self)) as! SearchVC
    }

    func photoDetailsVC() -> PhotoDetailsVC {
        return mainStoryboard().instantiateViewController(withIdentifier: String(describing: PhotoDetailsVC.self)) as! PhotoDetailsVC
    }

    // MARK: - Private
    private func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
