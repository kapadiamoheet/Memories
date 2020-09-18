//
//  PhotosViewController.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit
import Combine

class PhotosViewController: BaseViewController {
    var album: Album?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noRecordsLabel: UILabel!
    @IBOutlet weak var noRecordsContainerView: UIView!
    @IBOutlet weak var containerStack: UIStackView!
    
    private var viewModel: PhotosViewModel = PhotosViewModel()
    private var disposeBag = Set<AnyCancellable>()
    private var photoCellIdentifier = "PhotosCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupBindings()
        self.loadData()
    }
    
    private func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.viewModel.album = self.album
        self.title = self.album?.title ?? Screen.Photos.title.rawValue
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        self.noRecordsContainerView.isHidden = true
        self.noRecordsLabel.text = Messages.emptyAlbums
    }
    
    /// Description: Call to setup bindings with ViewModel State
    private func setupBindings() {
        self.viewModel.$state.receive(on: RunLoop.main).sink(receiveValue: {[weak self] state in
            guard let strongSelf = self else {
                return
            }
            strongSelf.collectionView.refreshControl?.endRefreshing()
            switch state {
            case .loading:
                                Logger.log(level: .debug, type: .printValue, message: "Showing Loader")
                                strongSelf.showSpinner()
            case .loaded(let data):
                strongSelf.renderData(data)
                strongSelf.hideSpinner()
                Logger.log(level: .debug, type: .printValue, message: "Photos loaded: \(data)")

                
            case .failed(let error):
                Logger.log(level: .debug, type: .generalError, message: "Received in fetching photos:\(error.localizedDescription)")
                strongSelf.hideSpinner()
                
            case .alert(let message):
                Logger.log(level: .debug, type: .printValue, message: "Show alert:\(message)")

                strongSelf.showAlert(with: message)
                strongSelf.noRecordsLabel.text = message
                strongSelf.hideSpinner()
            }
        }).store(in: &disposeBag)
    }
    
    /// Description: Call web service to fetch the data
    @objc private func loadData() {
        DispatchQueue.global().async {
            self.viewModel.fetchPhotos()
        }
    }
        
    /// Description: Called when retry button is tapped.
    /// - Parameter sender: retry button object
    @IBAction private func retryButtonAction(_ sender: Any) {
        self.loadData()
    }
    
    /// Description: Called when pull to refresh is performed.
    @objc private func refreshControlAction() {
        self.loadData()
    }

    /// Description: Call to reload the table view with updated dataSource
    /// - Parameter data: Array of Photo object.
    private func renderData(_ data:PhotoList) {
        self.noRecordsContainerView.isHidden = !data.isEmpty
        self.containerStack.isHidden = !self.noRecordsContainerView.isHidden
        self.collectionView.reloadData()
    }
}

//MARK: -- UICollectionViewDelegate & UICollectionViewDataSource --
extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotosCollectionViewCell
        let photo = self.viewModel.dataSource[indexPath.row]
        cell.setupValues(photo: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let photosViewerVC = Storyboards.main.instantiateViewController(withIdentifier: Screen.PhotosViewer.identifier.rawValue) as? PhotoViewerViewController {
            photosViewerVC.dataSource = self.viewModel.dataSource
            photosViewerVC.currentPageIndex = indexPath.row
            let navController = UINavigationController(rootViewController: photosViewerVC)
            self.present(navController, animated: true, completion: nil)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: -- UICollectionViewDelegateFlowLayout --
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        let sizeN = (size.width - 10) / 2.0 // 10 px on both side, and within, there is 10 px gap.
        let cellSize = CGSize(width: sizeN, height: sizeN)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(5)
    }
}
