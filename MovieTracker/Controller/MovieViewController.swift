//
//  GenreResultViewControllerTableViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/21/25.
//

import UIKit
import SwiftData

class MovieViewController: UITableViewController {
    var movieService: MovieService?
    var modelContext: ModelContext!
    var genre: Genre?
    var movies: [MovieItem] = []
    var favoriteMovies = [FavoriteMovie]()
    var currentPage: Int = 1
    var isLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthTheme.applyBackground(to: view)
        AuthTheme.configureNavigationBar(navigationController?.navigationBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .never
        title = genre?.name

        AuthTheme.styleMovieListTableView(tableView)
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 156

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesDidChange),
            name: .favoritesDidChange,
            object: nil
        )

        loadFavoriteMovies()
        if let genre {
            fetchMovies(for: genre, page: currentPage)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleFavoritesDidChange() {
        loadFavoriteMovies()
    }

    private func loadFavoriteMovies() {
        do {
            let fetchDescriptor = FetchDescriptor<FavoriteMovie>(
                sortBy: [SortDescriptor(\.title, order: .forward)]
            )
            favoriteMovies = try modelContext.fetch(fetchDescriptor)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }

    func fetchMovies(for genre: Genre, page: Int) {
        guard let movieService else { return }
        guard !isLoading else { return }
        isLoading = true

        var newMovies = [MovieItem]()
        tableView.tableFooterView = AuthTheme.makeLoadingFooter(width: tableView.bounds.width)

        Task {
            _ = await movieService.getMoviesByGenre(
                genreId: String(genre.id),
                page: currentPage
            ) { result in
                switch result {
                case .success(let response):
                    newMovies = response.data
                    self.movies.append(contentsOf: response.data)
                case .failure(let error):
                    print(error)
                }
            }

            await MainActor.run {
                self.isLoading = false
                self.tableView.tableFooterView = nil
                let oldCount = self.movies.count - newMovies.count
                let newCount = self.movies.count
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                if oldCount == 0 {
                    self.tableView.reloadData()
                } else {
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as! MovieTableViewCell

        let movie = movies[indexPath.row]
        let existingFavorite = favoriteMovies.first { $0.movieId == movie.id }
        let isFavorite = existingFavorite != nil

        cell.configure(movie: movie, isFavorite: isFavorite) { [weak self] in
            guard let self else { return }
            if let favorite = existingFavorite {
                self.removeFromFavorite(movie: favorite)
            } else {
                self.addToFavorite(movie: movie)
            }
        }
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 1.5, !isLoading, let genre {
            currentPage += 1
            fetchMovies(for: genre, page: currentPage)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = MovieDetailViewController()
        detailVC.movieService = movieService
        detailVC.movieId = movies[indexPath.row].id
        detailVC.modelContext = modelContext

        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func addToFavorite(movie: MovieItem) {
        let favorite = FavoriteMovie(
            movieId: movie.id,
            title: movie.title,
            posterURL: movie.poster
        )
        modelContext.insert(favorite)
        try? modelContext.save()
        loadFavoriteMovies()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)

        Task {
            guard let url = URL(string: movie.poster),
                  let (data, _) = try? await URLSession.shared.data(from: url) else {
                return
            }
            favorite.poster = data
            try? modelContext.save()
            await MainActor.run { self.loadFavoriteMovies() }
        }
    }

    private func removeFromFavorite(movie: FavoriteMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
        loadFavoriteMovies()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
}
