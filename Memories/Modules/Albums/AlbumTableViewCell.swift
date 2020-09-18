//
//  AlbumTableViewCell.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    @IBOutlet weak var albumTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupValues(album:Album) {
        self.albumTitle.text = album.title
    }
}
