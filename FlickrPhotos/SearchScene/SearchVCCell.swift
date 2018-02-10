//
//  SearchVCCell.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 10/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class SearchVCCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView?
    private var currentImageURL: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        setPlaceholderImage()
    }

    func setModel(_ model: SearchVCCellModel) {
        currentImageURL = model.imageURL
        setPlaceholderImage()
        model.getImage { [weak self] (image, url) in
            guard url == self?.currentImageURL else {return}
            if image != nil {
                self?.imageView?.image = image
            } else {
                //
            }
        }
    }

    private func setPlaceholderImage() {
        let placeholder = UIImage(named: "image_placeholder.jpg")
        imageView?.image = placeholder
    }
}
