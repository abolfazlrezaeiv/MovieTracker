//
//  MovieDetailsViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/18/25.
//

import UIKit

class MovieDetailViewController: UIViewController {
    var pageVC: UIPageViewController!
    @IBOutlet weak var imageBox: UIView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var countryBuiltLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var actorLabel: UILabel!
    var imagesUrl: [String] = [] // Your image names
    var currentIndex = 0
    var movieId: Int?
    var movieService: MovieService?

    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC = UIPageViewController(transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageVC.view.frame = imageBox.bounds
        pageVC.dataSource = self
        
        addChild(pageVC)
        imageBox.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        plotLabel.numberOfLines = 0
        plotLabel.lineBreakMode = .byWordWrapping
        actorLabel.numberOfLines = 0
        actorLabel.lineBreakMode = .byWordWrapping
        if let movieId = movieId {
            DispatchQueue.main.async {
                Task {
                    let movieDetails = await self.movieService?
                        .getMovieById(movieId)
                    self.imagesUrl = movieDetails?.images ?? []
                    self.movieTitle.text = movieDetails?.title
                    self.releaseYearLabel.text = movieDetails?.released
                    self.countryBuiltLabel.text = movieDetails?.country
                    self.plotLabel.text = movieDetails?.plot
                    self.actorLabel.text = movieDetails?.actors
                    if let firstVC = self.getVC(at: 0) {
                        self.pageVC.setViewControllers([firstVC], direction: .forward, animated: true)
                    }
                    
                }
            }
        }
    }
    
    func getVC(at index: Int) -> UIViewController? {
        guard index >= 0 && index < imagesUrl.count else { return nil }
        let vc = UIViewController()
        let imageView = UIImageView(frame: imageBox.bounds)
        
        if let url = URL(string: imagesUrl[index]) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil {
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        vc.view.addSubview(imageView)
        return vc
    }

}

extension MovieDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        currentIndex -= 1
        return getVC(at: currentIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        currentIndex += 1
        return getVC(at: currentIndex)
    }
}
