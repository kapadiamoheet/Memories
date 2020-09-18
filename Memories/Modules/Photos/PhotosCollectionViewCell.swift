//
//  PhotosCollectionViewCell.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit
import SDWebImage

class PhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 5.0
        self.thumbnailImg.contentMode = .scaleAspectFill
    }
    
    func setupValues(photo:Photo) {
        self.thumbnailImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if let thumbPath = photo.thumbnailUrl, let url = URL(string: thumbPath) {
            self.thumbnailImg.sd_setImage(with: url, completed: nil)
        }
    }
}
