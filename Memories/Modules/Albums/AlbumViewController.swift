//
//  AlbumViewController.swift
//  Memories
//
//  Created by Mohit Kapadia on 16/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import UIKit
import Combine

class AlbumViewController: BaseViewController {
    
    @IBOutlet weak var noRecordsLabel: UILabel!
    @IBOutlet weak var noRecordsContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: AlbumViewModel = AlbumViewModel()
    private var disposeBag = Set<AnyCancellable>()
    private var albumCellIdentifier = "AlbumTableViewCell"
    
    private var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadData()
        self.setupBindings()
    }
    
    /// Description: Setup initial UI
    private func setupUI() {
        //setup navigation item
        self.title = Screen.Album.title.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        //setup refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        
        //setup tableview
        self.tableView.refreshControl = refreshControl
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //no records label
        self.noRecordsContainerView.isHidden = true
        self.noRecordsLabel.text = Messages.emptyAlbums
        
        //setup search controller
        self.setupSearch()
    }
    
    /// Description: Call to setup bindings with ViewModel State
    private func setupBindings() {
        self.viewModel.$state.receive(on: RunLoop.main).sink(receiveValue: {[weak self] state in
            guard let strongSelf = self else {
                return
            }
            strongSelf.tableView.refreshControl?.endRefreshing()
            switch state {
            case .loading:
                Logger.log(level: .debug, type: .printValue, message: "Showing Loader")
                strongSelf.showSpinner()
                
            case .loaded(let data):
                strongSelf.renderData(data)
                strongSelf.hideSpinner()
                Logger.log(level: .debug, type: .printValue, message: "Albums loaded: \(data)")
                
            case .failed(let error):
                Logger.log(level: .debug, type: .generalError, message: "Received in fetching album:\(error.localizedDescription)")
                strongSelf.hideSpinner()
                
            case .alert(let message):
                Logger.log(level: .debug, type: .printValue, message: "Show alert:\(message)")
                strongSelf.showAlert(with: message)
                strongSelf.noRecordsLabel.text = message
                strongSelf.hideSpinner()
            }
        }).store(in: &disposeBag)
        
        self.viewModel.$filteredData
            .receive(on: RunLoop.main)
            .sink { (_) in
                self.tableView.reloadData()
                Logger.log(level: .debug, type: .printValue, message: "Loading filtered albums")
        }
        .store(in: &disposeBag)
    }
    
    
    /// Description: Call web service to fetch the data
    @objc func loadData() {
        DispatchQueue.global().async {
            self.viewModel.fetchAlbum()
        }
    }
    
    /// Description: Called when retry button is tapped.
    /// - Parameter sender: retry button object
    @IBAction func retryButtonAction(_ sender: Any) {
        self.loadData()
    }
    
    /// Description: Called when pull to refresh is performed.
    @objc func refreshControlAction() {
        self.loadData()
    }
    
    
    /// Description: Call to reload the table view with updated dataSource
    /// - Parameter data: Array of Album object.
    private func renderData(_ data:AlbumList) {
        self.noRecordsContainerView.isHidden = !data.isEmpty
        self.tableView.isHidden = !self.noRecordsContainerView.isHidden
        self.tableView.reloadData()
    }
}

//MARK: -- SearchController --
extension AlbumViewController {
    private func setupSearch() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = self.searchController
        self.searchController?.obscuresBackgroundDuringPresentation = false
        
        //notify for search keyword change
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification,                                                             object: self.searchController?.searchBar.searchTextField)
        .map {
            ($0.object as! UISearchTextField).text ?? ""
        }
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .assign(to: \.searchKey, on: self.viewModel)
        .store(in: &disposeBag)
        
        //notify for search cancel
        NotificationCenter.default.publisher(for: UISearchTextField.textDidEndEditingNotification,
                                             object: self.searchController?.searchBar.searchTextField)
            .map {
                ($0.object as! UISearchTextField).text ?? ""
        }
        .assign(to: \.searchKey, on: self.viewModel)
        .store(in: &disposeBag)
    }        
}

//MARK: -- UITableViewDelegate & UITableViewDataSource --
extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.listCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: albumCellIdentifier) as! AlbumTableViewCell
        let album = self.viewModel.filteredData[indexPath.row]
        cell.setupValues(album: album)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if indexpath mismatch with datasource, its better to crash
        let album = self.viewModel.filteredData[indexPath.row]
        if let photosVC = Storyboards.main.instantiateViewController(withIdentifier: Screen.Photos.identifier.rawValue) as? PhotosViewController {
            photosVC.album = album
            self.navigationController?.pushViewController(photosVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
