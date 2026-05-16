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
    var favoriteMovies = [FavoriteMovie]()
    var currentPage = 1
    var isSearch = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeAppearance()
        setupHomeUI()
        fetchMovies(page: currentPage, keyword: nil)
        currentPage = 1
        loadFavoriteMovies()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesDidChange),
            name: .favoritesDidChange,
            object: nil
        )
    }

    private func setupHomeUI() {
        AuthTheme.styleSearchBar(searchField)
        AuthTheme.styleMovieListTableView(movieListTableView)
        AuthTheme.addDismissKeyboardGesture(to: view)

        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        movieListTableView.rowHeight = UITableView.automaticDimension
        movieListTableView.estimatedRowHeight = 156
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthTheme.configureTabBar(tabBarController?.tabBar)
        loadFavoriteMovies()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleFavoritesDidChange() {
        loadFavoriteMovies()
    }
    
    func loadFavoriteMovies() {
        do {
            let fetchDescriptor = FetchDescriptor<FavoriteMovie>(
                sortBy: [SortDescriptor<FavoriteMovie>(\.title, order: .forward)]
            )
            let fetchResult = try modelContext?.fetch(fetchDescriptor)
            if let favorites = fetchResult {
                favoriteMovies = favorites
            }
            movieListTableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func removeFromFavorite(movie: FavoriteMovie) {
        modelContext.delete(movie)
        do {
            try modelContext.save()
            loadFavoriteMovies()
        } catch {
            print(error)
        }
    }
    
    func addToFavorite(movie: MovieItem) {
        let favorite = FavoriteMovie(
            movieId: movie.id,
            title: movie.title,
            posterURL: movie.poster
        )
        modelContext.insert(favorite)
        
        do {
            try modelContext.save()
            loadFavoriteMovies()
        } catch {
            print(error)
        }
        
        Task {
            guard let url = URL(string: movie.poster),
                  let (data, _) = try? await URLSession.shared.data(from: url) else {
                return
            }
            favorite.poster = data
            try? modelContext.save()
            await MainActor.run {
                self.loadFavoriteMovies()
            }
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
        
        let existingFavorite = favoriteMovies.first { $0.movieId == movies[indexPath.row].id }
        let isFavoriteItem = (existingFavorite != nil)
        
        cell.configure(movie: movies[indexPath.row], isFavorite: isFavoriteItem) {
            if let favorite = existingFavorite {
                self.removeFromFavorite(movie:favorite)
            } else {
                self.addToFavorite(movie: self.movies[indexPath.row])
            }
        }
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
        AuthTheme.makeLoadingFooter(width: movieListTableView.bounds.width)
    }
}


extension HomeViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let vc = MovieDetailViewController()
        vc.movieId = movies[indexPath.row].id
        vc.movieService = movieService
        vc.modelContext = modelContext

        navigationController?
            .pushViewController(
                vc,
                animated: true
            )
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchField.text, !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        currentPage = 1
        isSearch = true
        isLoading = false
        movies = []
        movieListTableView.reloadData()
        fetchMovies(page: currentPage, keyword: keyword)
        searchField.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard searchField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true, isSearch else {
            return
        }
        resetToBrowseMode()
    }

    private func resetToBrowseMode() {
        isSearch = false
        currentPage = 1
        isLoading = false
        movies = []
        movieListTableView.reloadData()
        fetchMovies(page: currentPage, keyword: nil)
    }
}

