//
//  PhotoViewerViewController.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit

class PhotoViewerViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var pageNoLabel: UILabel!
    var currentPageIndex: Int = 0
    var dataSource: PhotoList = []
    var totalCount: Int {
        self.dataSource.count
    }
    
    private var photoViewerCellIdentifier = "PhotoViewerCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.renderData(self.dataSource)
    }
    
    /// Description: Setup initial UI
    private func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
        
        self.title = Screen.Photos.title.rawValue
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissVC))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
        
    /// Description: Called on Cancel  button action from right bar button
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Description: Call to reload the table view with updated dataSource
    /// - Parameter data: Array of Photo object.
    private func renderData(_ data:PhotoList) {
        self.collectionView.reloadData()
        self.scrollToPage(self.currentPageIndex)
    }
    
    /// Description: Call
    /// - Parameter pageIndex: pageIndex index of the collection view to scroll
    private func setCurrentPage(_ pageIndex:Int) {
        self.currentPageIndex = pageIndex
        let pageNo = pageIndex + 1
        self.pageNoLabel.text = "\(pageNo)/\(self.totalCount)"
    }
    
    /// Description: Helper method to scroll collection to a given index
    /// - Parameter pageIndex: pageIndex index of the collection view to scroll
    private func scrollToPage(_ pageIndex:Int) {
        self.setCurrentPage(pageIndex)
        let idx = IndexPath(row: pageIndex, section: 0)
        Logger.log(level: .debug, type: .printValue, message: "Scroll to page:\(pageIndex)")
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: idx, at: .left, animated: false)
        }
    }
}

//MARK: -- UICollectionViewDelegate & UICollectionViewDataSource --
extension PhotoViewerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoViewerCellIdentifier, for: indexPath) as! PhotoViewerCollectionViewCell
        let photo = self.dataSource[indexPath.row]
        cell.setupValues(photo: photo)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        self.setCurrentPage(currentPage)
    }
}

//MARK: -- UICollectionViewDelegateFlowLayout --
extension PhotoViewerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
}

