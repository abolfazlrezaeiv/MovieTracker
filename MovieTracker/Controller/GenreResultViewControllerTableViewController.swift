//
//  GenreResultViewControllerTableViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/21/25.
//

import UIKit

class GenreResultViewControllerTableViewController: UITableViewController {
    var movieService: MovieService?
    var genre: Genre?
    var movies: [MovieItem] = []
    var currentPage: Int = 1
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MovieCustomCell.self, forCellReuseIdentifier: "MovieCell")
        title = genre?.name
        
        fetchMovies(for:genre!, page: currentPage)
        
    }
    
    
    func fetchMovies(for: Genre, page: Int) {
        guard let genre, let movieService else { return }
        var newMovies = [MovieItem]()
        guard !isLoading else { return }
        isLoading = true
        
        tableView.tableFooterView = createSpinnerFooter()
        Task{
            
            let _ = await movieService
                .getMoviesByGenre(genreId:String(genre.id), page: currentPage) { [weak self] result in
                    switch result {
                    case .success(let movies):
                        newMovies = movies.data
                        self?.movies.append(contentsOf: movies.data)
                    case .failure(let error):
                        print(error)
                    }
                }
            await MainActor.run {
                
                self.isLoading = false
                let oldCount = self.movies.count - newMovies.count
                let newCount = self.movies.count
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.tableFooterView = nil
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as! MovieCustomCell
        let movie = movies[indexPath.row]
        cell.configure(movie: movie)
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5 {
            // reached near the bottom
            if !isLoading {
                currentPage += 1
                if let genre = genre {
                    fetchMovies(
                        for: genre,
                        page: currentPage)
                    
                }
            }
        }
    }
    
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tableView.frame.size.width,
                height: 50
            )
        )
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        return footerView
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(
            identifier: "MovieDetailsVC"
        ) as! MovieDetailsViewController
        
        detailVC.movieService = movieService
        detailVC.movieId = movies[indexPath.row].id
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
