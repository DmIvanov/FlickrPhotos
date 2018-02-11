//
//  SearchVCDataModel.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class SearchVCDataModel {

    // MARK: - Properties
    private let dataService: DataService
    private let imageCache: ImageCache

    private var lastLoadedPage: UInt = 0
    private var loadingInProgress = false
    private var currentQuery = ""


    // MARK: - Lyfecycle
    init(dataService: DataService, imageCache: ImageCache? = nil) {
        self.dataService = dataService
        self.imageCache = imageCache ?? ImageCache(id: "searchVC", capacity: 300)
        tryToLoadPhotos()
    }


    // MARK: - Public
    func photosAmount() -> Int {
        return dataService.photos.count
    }

    func photoModel(index: Int) -> SearchVCCellModel? {
        guard index >= 0 && index < dataService.photos.count else {return nil}
        if dataService.photos.count - index < 30 {
            if !loadingInProgress {
                loadingInProgress = true
                tryToLoadPhotos()
            }
        }
        return SearchVCCellModel(photo: dataService.photos[index], imageCache: imageCache)
    }

    func detailesVCDataModel(index: Int) -> PhotoDetailsVCDataModel? {
        guard let photoModel = photoModel(index: index) else { return nil }
        return PhotoDetailsVCDataModel(imageCache: imageCache, photo: photoModel.photo)
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText != currentQuery {
            resetPhotos()
            currentQuery = searchText
            tryToLoadPhotos()
        }
    }

    func photosUpdated() {
        loadingInProgress = false
    }


    // MARK: - Private
    private func tryToLoadPhotos() {
        lastLoadedPage += 1
        dataService.loadPhotos(query: currentQuery, page: lastLoadedPage)
    }

    private func resetPhotos() {
        lastLoadedPage = 0
        dataService.resetPhotos()
    }
}
