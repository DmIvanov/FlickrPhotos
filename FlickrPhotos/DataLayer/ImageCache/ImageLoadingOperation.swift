//
//  ImageLoadingOperation.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 13/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class ImageLoadingOperation: Operation {

    var error: Error?
    var image: UIImage?
    var idx: Int = -1

    private let url: URL?

    init(idx: Int, imageURL: String) {
        url = URL(string: imageURL)
        self.idx = idx
    }

    override func main() {
        //print("op started \(idx)")
        if isCancelled {
            //print("+++ canceled before started")
            return
        }
        guard let url = url else {
            error = ImageLoadingError.InvalidURL
            return
        }
        do {
            //print("   op loading \(idx)")
            let data = try Data(contentsOf: url)
            image = UIImage(data: data)
            if image == nil {
                error = ImageLoadingError.CorruptedData
            }
        } catch {
            print(error.localizedDescription)
            self.error = error
        }
    }
}

enum ImageLoadingError: Error {
    case InvalidURL
    case CorruptedData
}
