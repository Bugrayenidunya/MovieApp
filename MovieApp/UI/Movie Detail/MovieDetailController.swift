//
//  MovieDetailController.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Kingfisher
import UIKit

class MovieDetailController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = MovieDetailViewModel()
    
    var movieDetail: Movie?
    private var similarMovies: [Movie] = []
    
    private var scrollView = UIScrollView()
    
    private let topViewMaxHeight: CGFloat = 442
    private let topViewMinHeight: CGFloat = 40 + UIStatusBarManager.accessibilityFrame().height
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTagline: UILabel!
    @IBOutlet weak var movieOverview: UITextView!
    @IBOutlet weak var movieRate: UILabel!
    @IBOutlet weak var movieRelaseDate: UILabel!
    @IBOutlet weak var imdbLogoImage: UIImageView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        scrollView.delegate = self
        
        navigationItem.title = movieDetail?.title
        
        // If movie has an id, fetch similar movies
        if let id = movieDetail?.id {
            viewModel.fetchSimilarMovies(id: id) { (result) in
                switch result {
                case .success(let movies):
                    DispatchQueue.main.async {
                        self.similarMovies = movies.results
                        self.tableView.reloadData()
                    }
                    // Check if there are Similar Movies
                    if movies.results.count < 1 {
                        // if no, hidden tableview
                        self.tableView.isHidden = true
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        // Recognize when tapped on to imdb logo
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.imdbImageTapped))
        imdbLogoImage.addGestureRecognizer(tapGR)
        
        // Set movie details
        if let overview = movieDetail?.overview, let tagline = movieDetail?.tagline, let rate = movieDetail?.voteAverage, let date = movieDetail?.releaseDate, let posterPath = movieDetail?.posterPath {
            
            let imageUrl = URL(string: "https://image.tmdb.org/t/p/original/\(posterPath)")
            
            moviePosterImage.kf.setImage(with: imageUrl)
            movieOverview.text = overview
            movieTagline.text = tagline
            movieRate.text = String(rate)
            movieRelaseDate.text = date
        }
        
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
    
    // MARK: Actions
    
    // When imdb logo tapped, open movie's imdb web page on default web browser
    @objc func imdbImageTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let imdbID = movieDetail?.imdbID {
                if let url = URL(string: "https://www.imdb.com/title/\(imdbID)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MovieDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = similarMovies[indexPath.row]
        
        let imageUrl = URL(string: "https://image.tmdb.org/t/p/original/\(movie.posterPath ?? "null")")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.UIConstant.movieDetailTableViewCell, for: indexPath) as? MovieDetailTableViewCell else { return UITableViewCell() }
        
        cell.similarMovieImage.kf.setImage(with: imageUrl)
        cell.similarMovieTitle.text = movie.title
        cell.similarMovieOverview.text = movie.overview
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "detailTableViewSectionTitle".localized
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if let movieID = similarMovies[indexPath.row].id {
            viewModel.fetchMovieDetail(id: movieID) { (result) in
                switch result {
                case .success(let movie):
                    DispatchQueue.main.async {
                        self.movieDetail = movie
                        self.performSegue(withIdentifier:Constant.SegueConstant.similarToDetail, sender: Any?.self)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    // When scrolling down to tableview's content, collapse collectionview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let y: CGFloat = scrollView.contentOffset.y
        let newCollectionViewHeight: CGFloat = topViewHeightConstraint.constant - y
        
        if newCollectionViewHeight > topViewMaxHeight {
            topViewHeightConstraint.constant = topViewMaxHeight
        } else if newCollectionViewHeight < topViewMinHeight {
            topViewHeightConstraint.constant = topViewMinHeight
        } else {
            topViewHeightConstraint.constant = newCollectionViewHeight
            // block scroll view
            scrollView.contentOffset.y = 0
        }
    }
    
}
