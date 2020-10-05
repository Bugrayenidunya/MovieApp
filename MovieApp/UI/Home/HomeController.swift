//
//  MovieController.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Alamofire
import Kingfisher
import UIKit

class HomeController: UIViewController {
    
    // MARK: Properties
    
    private let viewModel = HomeViewModel()
    
    private var nowPlayingMovies: [Movie] = []
    private var upcomingMovies: [Movie] = []
    private var movieDetail: Movie?
    
    private var scrollView = UIScrollView()
    
    private let collectionViewMaxHeight: CGFloat = 290
    private let collectionViewMinHeight: CGFloat = 40 + UIStatusBarManager.accessibilityFrame().height
    
    // MARK:  Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        scrollView.delegate = self
        
        navigationItem.title = "homeNavTitle".localized
        
        // Fetch Now Playing Movies
        viewModel.fetchNowPlayingMovies { (result) in
            switch result {
            case .success(let nowPlayingMovies):
                self.nowPlayingMovies = nowPlayingMovies.results
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.pageControl.numberOfPages = nowPlayingMovies.results.count
                }
            case .failure(let error):
                print(error)
            }
        }
        
        // Fetch Upcoming Movies
        viewModel.fetchUpcomingMovies { (result) in
            switch result {
            case .success(let upcomingMovies):
                self.upcomingMovies = upcomingMovies.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
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
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nowPlayingMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        pageControl.currentPage = indexPath.row
        
        let movie = nowPlayingMovies[indexPath.row]
        
        let imageUrl = URL(string: "https://image.tmdb.org/t/p/original/\(movie.posterPath ?? "null")")
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.UIConstant.homeCollectionViewCell, for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
        
        cell.nowPlayingImage.kf.setImage(with: imageUrl)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width - 10, height: frameSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let movieID = nowPlayingMovies[indexPath.row].id {
            viewModel.fetchMovieDetail(id: movieID) { (result) in
                switch result {
                case .success(let movie):
                    DispatchQueue.main.async {
                        self.movieDetail = movie
                        self.performSegue(withIdentifier:Constant.SegueConstant.homeToDetail, sender: Any?.self)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let movie = upcomingMovies[indexPath.row]
        
        let imageUrl = URL(string: "https://image.tmdb.org/t/p/original/\(movie.posterPath ?? "null")")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.UIConstant.homeTableViewCell, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.upcomingImage.kf.setImage(with: imageUrl)
        cell.movieTitle.text = movie.title
        cell.movieDescription.text = movie.overview
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "homeTableViewSectionTitle".localized
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if let movieID = upcomingMovies[indexPath.row].id {
            viewModel.fetchMovieDetail(id: movieID) { (result) in
                switch result {
                case .success(let movie):
                    DispatchQueue.main.async {
                        self.movieDetail = movie
                        self.performSegue(withIdentifier:Constant.SegueConstant.homeToDetail, sender: Any?.self)
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
        let newCollectionViewHeight: CGFloat = collectionViewHeightConstraint.constant - y
        
        if newCollectionViewHeight > collectionViewMaxHeight {
            collectionViewHeightConstraint.constant = collectionViewMaxHeight
        } else if newCollectionViewHeight < collectionViewMinHeight {
            collectionViewHeightConstraint.constant = collectionViewMinHeight
        } else {
            collectionViewHeightConstraint.constant = newCollectionViewHeight
            // Block scroll view
            scrollView.contentOffset.y = 0
        }
    }
    
}
