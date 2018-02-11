//
//  PhotoDetailsVC.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 11/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class PhotoDetailsVC: UIViewController {

    // MARK: - Properties
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var details: UILabel!
    var dataModel: PhotoDetailsVCDataModel!

    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = dataModel.title()
        fillIn()
    }

    // MARK: - Public


    // MARK: - Private
    private func fillIn() {
        dataModel.getImage(completion: { (image, url) in
            self.imageView.image = image
        })
        details.text = dataModel.detailesText()
    }

    // MARK: - Actions
}
