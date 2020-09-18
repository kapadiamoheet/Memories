//
//  AlbumViewModel.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation
import Combine

protocol AlbumUseCases {
    func fetchAlbum()
}

class AlbumViewModel: ObservableObject {
    @Published var state: State<AlbumList> = .loading
    @Published var filteredData: AlbumList = []
    
    var searchKey:String = "" {
        didSet {
            self.filterDataSource(for: self.searchKey)
        }
    }
    
    var dataSource: AlbumList = [] {
        didSet {
            self.filteredData = self.dataSource
        }
    }
    
    var listCount: Int {
        self.filteredData.count
    }
    
    private var disposeBag = Set<AnyCancellable>()
        
    func fetchAlbum() {
        let request: GetAlbumRequest = GetAlbumRequest(userId: 1)
        let manager: AlbumManager<AlbumList> = AlbumManager<AlbumList>()
        Logger.log(level: .debug, type: .printValue, message: "Fetching Albums for UserId: \(request.userId)")
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
    
    func update(model:AlbumList?) {
        if let data = model {
            self.dataSource = data
            self.state = .loaded(data)
            if data.isEmpty {
                self.showMessage(Messages.emptyAlbums)
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
    
    func filterDataSource(for key:String) {
        Logger.log(level: .debug, type: .printValue, message:"Filtering Albums for key:\(key)")
        if key.isEmpty {
            self.filteredData = self.dataSource
        } else {
            self.filteredData = self.dataSource.filter { $0.title?.lowercased().contains(key.lowercased()) ?? false}
        }
    }
}
