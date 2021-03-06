//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

struct Photo: Codable {
    let farm: Int
    let id: String
    let server: String
    let secret: String
    let title: String?

    func imageURL() -> String {
        return imageURL(size: "b")
    }

    func thumbnailURL() -> String {
        return imageURL(size: "m")
    }

    private func imageURL(size: String) -> String {
        return "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
    }
}
