//
//  PhotoViewerCollectionViewCell.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageView.contentMode = .scaleAspectFit
    }
    
    func setupValues(photo:Photo) {
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if let imagePath = photo.url, let url = URL(string: imagePath) {
            self.imageView.sd_setImage(with: url, completed: nil)
        }
    }
}
