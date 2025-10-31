//
//  ViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/16/25.
//

import UIKit
import SwiftData

class HomeViewController: UIViewController {
    @IBOutlet weak var movieListTableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    var movieService: MovieService?
    var modelContext: ModelContext!
    var movies: [MovieItem] = []
    var favoriteMovies = Set<String>()
    var currentPage = 1
    var isSearch = false
    var isLoading = false
    
    override func viewDidLoad() {
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView
            .register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        movieListTableView.rowHeight = UITableView.automaticDimension
        movieListTableView.estimatedRowHeight = 200 // any reasonable guess
        fetchMovies(page: currentPage, keyword: nil)
        currentPage = 1
        super.viewDidLoad()
    }
    
    func loadFavoriteMovies() -> [FavoriteMovie] {
        do {
            var fetchDescriptor = FetchDescriptor<FavoriteMovie>(sortBy: [SortDescriptor<FavoriteMovie>(\.title, order: .forward)])
            
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print(error)
            return []
        }
    }
    
    func addToFavorite(movie: MovieItem) {
        var favorite = FavoriteMovie(title: movie.title, )
        modelContext.insert(favorite)
        
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func fetchMovies(page: Int, keyword: String?) {
        guard !isLoading else { return }
        isLoading = true
        var newMovie = [MovieItem]()
        var result = [MovieItem]()
        // show footer loader
        movieListTableView.tableFooterView = createSpinnerFooter()
        Task {
            if isSearch, let keyword = keyword {
                result = await movieService?
                    .searchMovies(keyword: keyword, page: currentPage) ?? []
            } else {
                
                 result = await self.movieService?.fetchMovies(page: page) ?? []
            }
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


extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath) as! MovieTableViewCell
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
                fetchMovies(page: currentPage,keyword: searchField.text)
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


extension HomeViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as! MovieDetailViewController
        vc.movieId = movies[indexPath.row].id
        vc.movieService = movieService
        
        navigationController?
            .pushViewController(
                vc,
                animated: true
            )
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchField.text else {
            return
        }
        currentPage = 1
        isSearch = true
        Task {
            movies = await movieService?
                .searchMovies(keyword: keyword, page: currentPage) ?? []
            movieListTableView.reloadData()
        }
        searchField.resignFirstResponder()
    }
}

