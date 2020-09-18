//
//  Album.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation

// MARK: - Album
struct Album: Codable {
    var userId, id: Int?
    var title: String?

    enum CodingKeys: String, CodingKey {
        case userId
        case id, title
    }
}

typealias AlbumList = [Album]

struct GetAlbumRequest {
    var userId:Int
    var endPoint: String {
        return String(format: AppURL.getAlbums, userId)
    }
}

