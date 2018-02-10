//
//  ViewControllerFactory.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class ViewControllerFactory: NSObject {

    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    class func searchVC() -> SearchVC {
        return mainStoryboard().instantiateViewController(withIdentifier: String(describing: SearchVC.self)) as! SearchVC
    }
}
