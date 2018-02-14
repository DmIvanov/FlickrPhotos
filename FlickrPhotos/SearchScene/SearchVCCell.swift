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

    @IBOutlet var imageView: UIImageView?
    private var model: SearchVCCellModel?

    var idx: Int = -1

    override func prepareForReuse() {
        super.prepareForReuse()
        print("reuse \(idx)")
        imageView?.image = SearchVCCell.placeholder
    }

    func setModel(idx: Int, model: SearchVCCellModel) {
        self.idx = idx
        imageView?.image = SearchVCCell.placeholder
        self.model = model
        model.getImage(idx: idx) { [weak self] (image, loadedURL) in
            if image != nil {
                self?.imageView?.image = image
            } else {
                //
            }
        }
    }

    func refresh(idx: Int) {
        model?.cancelImageLoading(idx: idx)
        model = nil
        imageView?.image = nil
    }
}
