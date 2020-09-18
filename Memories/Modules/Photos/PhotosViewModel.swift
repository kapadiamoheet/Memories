//
//  PhotosViewModel.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation
import Combine

protocol PhotosUseCases {
    func fetchPhotos()
}

class PhotosViewModel: PhotosUseCases, ObservableObject {
    @Published var state: State<PhotoList> = .loading
    var album:Album?
    var dataSource: PhotoList = []
    var listCount: Int {
        self.dataSource.count
    }
    
    private var disposeBag = Set<AnyCancellable>()
        
    func fetchPhotos() {
        guard let albumId = self.album?.id else {
            return
        }
        let request = GetPhotosRequest(albumId: albumId)
        let manager: PhotoManager<PhotoList> = PhotoManager<PhotoList>()
        manager.fetch(request: request)
            .receive(on: DispatchQueue.global())
            .eraseToAnyPublisher()
            .sink(receiveCompletion: {[weak self] completion in
                guard let strongSelf = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    strongSelf.showMessage(error.localizedDescription)
                }
            }) {[weak self] (response) in
                guard let strongSelf = self else { return }
                let list = response.value
                strongSelf.update(model: list)
                
        }.store(in: &disposeBag)
    }
    
    func update(model:PhotoList?) {
        if let data = model {
            self.dataSource = data
            self.state = .loaded(data)
            if data.isEmpty {
                self.showMessage(Messages.emptyPhotos)
            }
        } else {
            self.state = .failed(AppError.nilValue)
        }
    }
    
    func showMessage(_ message:String?) {
        if let msg = message {
            self.state = .alert(msg)
        }
    }
}


