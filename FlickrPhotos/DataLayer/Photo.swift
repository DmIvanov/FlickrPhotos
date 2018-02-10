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
}
