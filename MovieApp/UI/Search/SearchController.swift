//
//  SearchController.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 1.10.2020.
//

import UIKit
import WebKit

class SearchController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = SearchViewModel()
    
    private var searchedMovies: [Movie] = []
    private var movieDetail: Movie?
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.placeholder = "searchPlaceholder".localized
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "searchNavTitle".localized
        
        // With UIViewController extension
        self.hideKeyboardWhenTappedAround()
    }
    
    // For passing data to MovieDetailController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MovieDetailController {
            let vc = segue.destination as? MovieDetailController
            vc?.movieDetail = self.movieDetail
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchController: UISearchBarDelegate {
    // Check search term length and reload data at the same time while typing
    @objc func reload() {
        guard let searchText = searchBar.text else { return }
        if searchText.count >= 2 {
            self.viewModel.searchMovie(with: searchText) { (result) in
                switch result {
                case .success(let searchedMovies):
                    DispatchQueue.main.async {
                        self.searchedMovies = searchedMovies.results
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            // instead of using if-else, use return here
            return
        }
        // If search term's length is smaller than 2 char
        searchedMovies = []
        self.tableView.reloadData()
    }
    
    // After 0.2 ms, text changed inside search bar, call reload func
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.2)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = searchedMovies[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.UIConstant.searchTableCell, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = movie.originalTitle
        cell.detailTextLabel?.text = movie.releaseDate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if let movieID = searchedMovies[indexPath.row].id {
            viewModel.fetchMovieDetail(id: movieID) { (result) in
                switch result {
                case .success(let movie):
                    DispatchQueue.main.async {
                        self.movieDetail = movie
                        self.performSegue(withIdentifier:Constant.SegueConstant.searchToDetail, sender: Any?.self)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
