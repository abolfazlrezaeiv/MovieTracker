//
//  ViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//

import UIKit

class MovieController: UIViewController {
    @IBOutlet weak var movieListTableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    var movieService: MovieService?
    var movies: [MovieItem] = []
    var currentPage = 1
    var isLoading = false
    
    override func viewDidLoad() {
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView
            .register(MovieCustomCell.self, forCellReuseIdentifier: "MovieCell")
        movieListTableView.rowHeight = UITableView.automaticDimension
        movieListTableView.estimatedRowHeight = 200 // any reasonable guess
        fetchMovies(page: currentPage)
        super.viewDidLoad()
    }
    
    func fetchMovies(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        var newMovie = [MovieItem]()
        
        // show footer loader
        movieListTableView.tableFooterView = createSpinnerFooter()
        Task {
            let result = await self.movieService?.fetchMovies(page: page) ?? []
            self.isLoading = false
            self.movieListTableView.tableFooterView = nil
            newMovie = result
            // Always update UI on the main actor
            await MainActor.run {
                self.movies += result
            }
            let oldCount = movies.count - newMovie.count
            let newCount = movies.count
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            
            movieListTableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}


extension MovieController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath) as! MovieCustomCell
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5 {
            // reached near the bottom
            if !isLoading {
                currentPage += 1
                fetchMovies(page: currentPage)
            }
        }
    }
    
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: movieListTableView.frame.size.width,
                height: 50
            )
        )
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        return footerView
    }
}


extension MovieController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as! MovieDetailsViewController
        vc.movieId = movies[indexPath.row].id
        vc.movieService = movieService
        
        navigationController?
            .pushViewController(
                vc,
                animated: true
            )
    }
}

extension MovieController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchField.text else {
            return
        }
        Task {
            movies = await movieService?
                .searchMovies(keyword: keyword, page: 1) ?? []
            movieListTableView.reloadData()
        }
        searchField.resignFirstResponder()
    }
}

