//
//  FavoriteMoviesViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 11/16/25.
//
import UIKit
import SwiftData

class FavoriteMoviesViewController: UIViewController {
    var modelContext: ModelContext!
    var movieService: MovieService?

    private var tableView: UITableView!
    private var emptyStateView: UIView!
    private var favoriteMovies = [FavoriteMovie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthTheme.applyBackground(to: view)
        AuthTheme.configureNavigationBar(navigationController?.navigationBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .never
        title = "My List"
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteMovies()
    }

    private func setupUI() {
        tableView = UITableView()
        AuthTheme.styleMovieListTableView(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 156
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView = AuthTheme.makeEmptyStateView(
            icon: "heart",
            title: "No favorites yet",
            message: "Tap the heart on any movie from Home or Genres to build your list."
        )
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true

        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadFavoriteMovies() {
        do {
            let fetchDescriptor = FetchDescriptor<FavoriteMovie>(
                sortBy: [SortDescriptor(\.title, order: .forward)]
            )
            favoriteMovies = try modelContext.fetch(fetchDescriptor)
            updateUI()
        } catch {
            print(error)
        }
    }

    private func updateUI() {
        let isEmpty = favoriteMovies.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        if isEmpty {
            tableView.tableHeaderView = nil
        } else {
            tableView.tableHeaderView = AuthTheme.makeListHeaderView(
                title: "Favorites",
                count: favoriteMovies.count
            )
        }

        tableView.reloadData()
    }

    private func removeFromFavorite(movie: FavoriteMovie) {
        modelContext.delete(movie)
        do {
            try modelContext.save()
            loadFavoriteMovies()
            NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        } catch {
            print(error)
        }
    }
}

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}

extension FavoriteMoviesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as! MovieTableViewCell

        let favorite = favoriteMovies[indexPath.row]
        cell.configure(favorite: favorite) { [weak self] in
            self?.removeFromFavorite(movie: favorite)
        }
        return cell
    }
}

extension FavoriteMoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = favoriteMovies[indexPath.row]
        guard favorite.movieId > 0 else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MovieDetailsVC") as! MovieDetailViewController
        vc.movieId = favorite.movieId
        vc.movieService = movieService
        navigationController?.pushViewController(vc, animated: true)
    }
}
