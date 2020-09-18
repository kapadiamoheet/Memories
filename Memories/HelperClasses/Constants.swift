//
//  Constants.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit

//MARK: -- UI State --
enum State<T> {
    case loading
    case loaded(T)
    case failed(Error)
    case alert(String)
}

//MARK: -- Messages --
struct Messages {
    static let emptyAlbums = "You do not have any albums"
    static let emptyPhotos = "You do not have any photos in this album"
}

//MARK: -- AppError --
enum AppError: Error {
    case nilValue
    case invalidData
}

//MARK: -- Screen --
enum Screen {
    enum Album: String {
        case title = "Albums"
        case identifier = "AlbumViewController"
    }
    
    enum Photos: String {
        case title = "Photos"
        case identifier = "PhotosViewController"
    }
    
    enum PhotosViewer: String {
        case title = "Photos"
        case identifier = "PhotoViewerViewController"
    }
}

//MARK: -- AppInfo --
struct Storyboards {
    enum Names: String {
        case main = "Main"
    }
    
    static let main = UIStoryboard(name: Names.main.rawValue, bundle: nil)
}

//MARK: -- AppInfo --
/// Description: All App related information can be access
class AppInfo {
    /// Description: Call to get App Name
    static var name: String {
        // swiftlint:disable:next force_cast
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    /// Description: Call to get App version
    static var version: String {
        // swiftlint:disable:next force_cast
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}
