//
//  MovieDetailsViewController.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/18/25.
//

import UIKit
import SwiftData

class MovieDetailViewController: UIViewController {
    var movieId: Int?
    var movieService: MovieService?
    var modelContext: ModelContext?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let imageBox = UIView()
    private var pageVC: UIPageViewController!
    private let pageControl = UIPageControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let genresLabel = UILabel()
    private let ratingBadge = AuthTheme.makeRatingBadge(text: "")
    private let plotSectionLabel = AuthTheme.makeSectionTitleLabel("Plot")
    private let plotLabel = AuthTheme.makeDetailBodyLabel()
    private let castSectionLabel = AuthTheme.makeSectionTitleLabel("Cast")
    private let actorLabel = AuthTheme.makeDetailBodyLabel()
    private let crewLabel = AuthTheme.makeDetailBodyLabel()

    private var imagesUrl: [String] = []
    private var currentPageIndex = 0
    private var loadedMovie: MovieDetails?
    private var favoriteRecord: FavoriteMovie?

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthTheme.applyBackground(to: view)
        AuthTheme.configureNavigationBar(navigationController?.navigationBar)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .never

        view.subviews.forEach { $0.removeFromSuperview() }
        setupUI()
        setupPageViewController()
        loadMovie()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        imageBox.backgroundColor = AuthTheme.surface
        imageBox.clipsToBounds = true
        imageBox.translatesAutoresizingMaskIntoConstraints = false

        pageControl.currentPageIndicatorTintColor = AuthTheme.accent
        pageControl.pageIndicatorTintColor = AuthTheme.textSecondary.withAlphaComponent(0.4)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isHidden = true
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = AuthTheme.textPrimary
        titleLabel.numberOfLines = 0

        metaLabel.font = .systemFont(ofSize: 15, weight: .medium)
        metaLabel.textColor = AuthTheme.textSecondary
        metaLabel.numberOfLines = 0

        genresLabel.font = .systemFont(ofSize: 14, weight: .regular)
        genresLabel.textColor = AuthTheme.textSecondary
        genresLabel.numberOfLines = 0

        ratingBadge.isHidden = true

        let infoCard = makeInfoCard()
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(imageBox)
        contentStack.addArrangedSubview(pageControl)
        contentStack.addArrangedSubview(infoCard)

        activityIndicator.color = AuthTheme.accent
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            imageBox.heightAnchor.constraint(equalToConstant: 320),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeInfoCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AuthTheme.surface
        card.layer.cornerRadius = 20
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.layer.borderWidth = 1
        card.layer.borderColor = AuthTheme.fieldBorder.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            metaLabel,
            genresLabel,
            ratingBadge,
            plotSectionLabel,
            plotLabel,
            castSectionLabel,
            actorLabel,
            crewLabel
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.setCustomSpacing(16, after: ratingBadge)
        stack.setCustomSpacing(6, after: plotSectionLabel)
        stack.setCustomSpacing(16, after: plotLabel)
        stack.setCustomSpacing(6, after: castSectionLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AuthTheme.horizontalPadding),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AuthTheme.horizontalPadding),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])

        let wrapper = UIView()
        wrapper.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -20),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])
        return wrapper
    }

    private func setupPageViewController() {
        pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageVC.dataSource = self
        pageVC.delegate = self

        addChild(pageVC)
        imageBox.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: imageBox.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: imageBox.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: imageBox.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: imageBox.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            AuthTheme.background.withAlphaComponent(0.85).cgColor
        ]
        gradient.locations = [0.55, 1.0]
        imageBox.layer.addSublayer(gradient)
        imageBox.layoutIfNeeded()
        gradient.frame = imageBox.bounds
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = imageBox.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = imageBox.bounds
        }
    }

    private func loadMovie() {
        guard let movieId else { return }
        activityIndicator.startAnimating()
        scrollView.isHidden = true

        Task {
            let details = await movieService?.getMovieById(movieId)
            await MainActor.run {
                self.activityIndicator.stopAnimating()
                self.scrollView.isHidden = false
                guard let details else { return }
                self.applyMovieDetails(details)
            }
        }
    }

    private func applyMovieDetails(_ movie: MovieDetails) {
        loadedMovie = movie
        title = movie.title
        navigationItem.title = movie.title

        titleLabel.text = movie.title
        metaLabel.text = [movie.released, movie.runtime, movie.rated]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        genresLabel.text = movie.genres.joined(separator: " · ")
        genresLabel.isHidden = movie.genres.isEmpty

        if !movie.imdbRating.isEmpty {
            ratingBadge.isHidden = false
            if let label = ratingBadge.arrangedSubviews.last as? UILabel {
                label.text = "IMDb \(movie.imdbRating)"
            }
        } else {
            ratingBadge.isHidden = true
        }

        plotLabel.text = movie.plot
        actorLabel.text = movie.actors
        crewLabel.text = movie.director.isEmpty ? nil : "Director: \(movie.director)"
        crewLabel.isHidden = movie.director.isEmpty

        imagesUrl = movie.images.isEmpty ? [movie.poster] : movie.images
        pageControl.numberOfPages = imagesUrl.count
        pageControl.isHidden = imagesUrl.count <= 1
        currentPageIndex = 0

        if let first = imagePageViewController(at: 0) {
            pageVC.setViewControllers([first], direction: .forward, animated: false)
        }

        refreshFavoriteState()
        updateFavoriteButton()
    }

    private func refreshFavoriteState() {
        guard let modelContext, let movieId else { return }
        do {
            let descriptor = FetchDescriptor<FavoriteMovie>()
            let favorites = try modelContext.fetch(descriptor)
            favoriteRecord = favorites.first { $0.movieId == movieId }
        } catch {
            print(error)
        }
    }

    private func updateFavoriteButton() {
        guard modelContext != nil else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let isFavorite = favoriteRecord != nil
        let imageName = isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        navigationItem.rightBarButtonItem?.tintColor = AuthTheme.accent
    }

    @objc private func toggleFavorite() {
        guard let modelContext, let movie = loadedMovie else { return }

        if let favorite = favoriteRecord {
            modelContext.delete(favorite)
            try? modelContext.save()
            favoriteRecord = nil
        } else {
            let favorite = FavoriteMovie(
                movieId: movie.id,
                title: movie.title,
                posterURL: movie.poster
            )
            modelContext.insert(favorite)
            try? modelContext.save()
            favoriteRecord = favorite

            Task {
                guard let url = URL(string: movie.poster),
                      let (data, _) = try? await URLSession.shared.data(from: url) else {
                    return
                }
                favorite.poster = data
                try? modelContext.save()
            }
        }

        updateFavoriteButton()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }

    @objc private func pageControlChanged() {
        let newIndex = pageControl.currentPage
        guard newIndex != currentPageIndex,
              let vc = imagePageViewController(at: newIndex) else { return }
        let direction: UIPageViewController.NavigationDirection =
            newIndex > currentPageIndex ? .forward : .reverse
        pageVC.setViewControllers([vc], direction: direction, animated: true) { completed in
            if completed {
                self.currentPageIndex = newIndex
            }
        }
    }

    private func imagePageViewController(at index: Int) -> UIViewController? {
        guard index >= 0, index < imagesUrl.count else { return nil }
        let vc = UIViewController()
        vc.view.tag = index
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AuthTheme.background
        imageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])

        if let url = URL(string: imagesUrl[index]) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil, let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
        }
        return vc
    }
}

extension MovieDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        imagePageViewController(at: viewController.view.tag - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        imagePageViewController(at: viewController.view.tag + 1)
    }
}

extension MovieDetailViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed, let current = pageViewController.viewControllers?.first else { return }
        currentPageIndex = current.view.tag
        pageControl.currentPage = currentPageIndex
    }
}
