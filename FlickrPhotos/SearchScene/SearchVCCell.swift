//
//  SearchVCCell.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class SearchVCCell: UICollectionViewCell {

    private static let placeholder = UIImage(named: "image_placeholder.jpg")

    @IBOutlet var imageView: UIImageView!
    private var model: SearchVCCellModel?

    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        imageView?.image = SearchVCCell.placeholder
    }

    func setModel(model: SearchVCCellModel) {
        imageView.image = SearchVCCell.placeholder
        self.model = model
        loadImage() 
    }

    func didEndDisplaying(idx: Int) {
        model?.cancelImageLoading()
    }

    func willBeginDisplaying() {
        loadImage()
    }


    private func loadImage() {
        model?.getImage() { [weak self] (image, loadedURL) in
            if image != nil {
                self?.imageView.image = image
            } else {
                //
            }
        }
    }
}
