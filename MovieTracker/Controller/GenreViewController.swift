//
//  MovieCategoryViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/19/25.
//

import UIKit

class GenreViewController: UIViewController {
    var genresCollectionView: UICollectionView!
    var movieService: MovieService!
    
    var genres: [Genre] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        
        self.genresCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        self.genresCollectionView.backgroundColor = .systemBackground
        
        view.addSubview(genresCollectionView)
        setupViews()
        
        genresCollectionView.register(
            GenreCollectionViewCell.self,
            forCellWithReuseIdentifier: "GenreCell")
        loadGenres()
        self.genresCollectionView.dataSource = self
        self.genresCollectionView.delegate = self
        
    }
    
    func setupViews() {
        genresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            genresCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            genresCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            genresCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func loadGenres() {
        Task {
            do {
                let genres = try await self.movieService?.getGenres()
                await MainActor.run {
                    self.genres = genres ?? []
                    self.genresCollectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Failed to Load Genres",
                                                  message: (error as NSError).localizedDescription,
                                                  preferredStyle: .alert)
                    alert
                        .addAction(
                            UIAlertAction(
                                title: "OK",
                                style: .default,
                                handler: { _ in
                                    alert.dismiss(animated: true)
                                }
                            )
                        )
                    self.present(alert, animated: true)
                }
            }
          
        }
    }
}

extension GenreViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedMovie = genres[indexPath.row]
        
        let genreResultViewControllerTableViewController = MovieViewController()
        genreResultViewControllerTableViewController.genre = selectedMovie
        genreResultViewControllerTableViewController.movieService = self.movieService
        genreResultViewControllerTableViewController.currentPage = 1
        
        navigationController?
            .pushViewController(
                genreResultViewControllerTableViewController,
                animated: true
            )
    }
    
}


extension GenreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GenreCell",
            for: indexPath
        ) as! GenreCollectionViewCell
        cell.configure(with: genres[indexPath.row])
        return cell
    }
}

extension GenreViewController: UICollectionViewDelegateFlowLayout {
    // Define the size of each item
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 10
        let totalPadding = padding * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - totalPadding
        let itemWidth = availableWidth / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // Define spacing between cells
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // Optional: add padding on the sides
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

