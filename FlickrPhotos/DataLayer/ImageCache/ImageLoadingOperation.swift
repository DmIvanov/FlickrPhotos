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

    private let url: URL?

    init(imageURL: String) {
        url = URL(string: imageURL)
    }

    override func main() {
        if isCancelled {
            return
        }
        guard let url = url else {
            error = ImageLoadingError.InvalidURL
            return
        }
        do {
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
