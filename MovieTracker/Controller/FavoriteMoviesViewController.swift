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
    private var favoriteMovies = [FavoriteMovie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorite movies"
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteMovies()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
