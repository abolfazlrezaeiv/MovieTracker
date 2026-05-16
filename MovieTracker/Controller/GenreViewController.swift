//
//  MovieCategoryViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/19/25.
//

import UIKit
import SwiftData

class GenreViewController: UIViewController {
    var genresCollectionView: UICollectionView!
    var movieService: MovieService!
    var modelContext: ModelContext!

    var genres: [Genre] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeAppearance(title: "Genres")
        setupCollectionView()
        loadGenres()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthTheme.configureTabBar(tabBarController?.tabBar)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12

        genresCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        AuthTheme.styleGenresCollectionView(genresCollectionView)
        genresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        genresCollectionView.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: "GenreCell")
        genresCollectionView.dataSource = self
        genresCollectionView.delegate = self

        view.addSubview(genresCollectionView)
        NSLayoutConstraint.activate([
            genresCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadGenres() {
        Task {
            do {
                let genres = try await movieService.getGenres()
                await MainActor.run {
                    self.genres = genres
                    self.genresCollectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Could not load genres",
                        message: (error as NSError).localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension GenreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedGenre = genres[indexPath.row]

        let moviesVC = MovieViewController()
        moviesVC.genre = selectedGenre
        moviesVC.movieService = movieService
        moviesVC.modelContext = modelContext
        moviesVC.currentPage = 1

        navigationController?.pushViewController(moviesVC, animated: true)
    }
}

extension GenreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genres.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GenreCell",
            for: indexPath
        ) as! GenreCollectionViewCell
        cell.configure(with: genres[indexPath.row])
        return cell
    }
}

extension GenreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let padding = AuthTheme.horizontalPadding
        let spacing: CGFloat = 12
        let itemsPerRow: CGFloat = 2
        let totalSpacing = spacing * (itemsPerRow - 1) + padding * 2
        let width = (collectionView.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: 108)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 8,
            left: AuthTheme.horizontalPadding,
            bottom: 20,
            right: AuthTheme.horizontalPadding
        )
    }
}
