//
//  PhotosManager.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation
import Combine

//MARK: -- PhotoRepository --
protocol PhotoRepository {
    associatedtype Model: Decodable

    /// Description: Call to fetch contacts from server
    ///
    /// - Parameter param: Optional parameters for fetch query from server
    func fetch(request:GetPhotosRequest) -> AnyPublisher<ServiceResponse<Model>,Error>
}

class PhotoManager<DataModel:Codable>: PhotoRepository {
    typealias Model = DataModel
    private let networkWorker: NetworkWorker
    private let decoder = JSONDecoder()
    init(networkWorker:NetworkWorker = NetworkWorker.shared) {
        self.networkWorker = networkWorker
    }
    
    func fetch(request:GetPhotosRequest) -> AnyPublisher<ServiceResponse<Model>,Error> {
        let wsDetail = WebServiceDetail(urlEndPoint: request.endPoint, method: .get, parameters: nil)
        return self.networkWorker.callAPI(for: wsDetail)
    }
}
