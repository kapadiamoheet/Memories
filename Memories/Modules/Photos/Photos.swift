//
//  Photos.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation


// MARK: - Photo
struct Photo: Codable {
    var albumId, id: Int?
    var title: String?
    var url, thumbnailUrl: String?

    enum CodingKeys: String, CodingKey {
        case albumId
        case id, title, url
        case thumbnailUrl
    }
}

typealias PhotoList = [Photo]

struct GetPhotosRequest {
    var albumId:Int
    var endPoint: String {
        return String(format: AppURL.getPhotos, albumId)
    }
}
