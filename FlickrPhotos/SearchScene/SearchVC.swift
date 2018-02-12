//
//  SearchVC.swift
//  FlickrPhotos
//
//  Created by Dmitrii on 08/02/2018.
//  Copyright © 2018 DI. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    // MARK: - Properties
    fileprivate let cardCellId = "PhotoCellId"
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

    @IBOutlet private var collectionView: UICollectionView!

    private var searchController: UISearchController!
    private var dataModel: SearchVCDataModel! 


    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        configureSearchController()
        //navigationController?.hidesBarsOnSwipe = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosUpdated),
            name: DataService.dsPhotosUpdateSucceededNotification,
            object: nil
        )
    }

    override func viewWillLayoutSubviews() {
        let layout = collectionView.collectionViewLayout
        layout.invalidateLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - Public

    func setDataService(ds: DataService) {
        dataModel = SearchVCDataModel(dataService: ds)
    }


    // MARK: - Private
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.barTintColor = UIColor.lightGray
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        definesPresentationContext = true
    }

    @objc private func photosUpdated() {
        dataModel.photosUpdated()
        collectionView.reloadData()
    }
}


extension SearchVC: UISearchResultsUpdating, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        dataModel.filterContentForSearchText(searchController.searchBar.text!)
    }
}


extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailsDataModel = dataModel.detailesVCDataModel(index: indexPath.item) else { return }
        let vc = ViewControllerFactory().photoDetailsVC()
        vc.dataModel = detailsDataModel
        navigationController?.pushViewController(vc, animated: true)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.photosAmount()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardCellId, for: indexPath) as! SearchVCCell
        if let photoModel = dataModel.photoModel(index: indexPath.item) {
            cell.setModel(photoModel)
        }
        return cell
    }
}


extension SearchVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        var availableWidth: CGFloat!
        if #available(iOS 11.0, *) {
            availableWidth = view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right - paddingSpace
        } else {
            availableWidth = view.frame.width - paddingSpace
        }
        let widthPerItem = floor(availableWidth / itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
