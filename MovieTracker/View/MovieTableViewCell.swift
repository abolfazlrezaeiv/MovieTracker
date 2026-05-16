//
//  MovieCustomCell.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/17/25.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let genresLabel = UILabel()
    private let ratingBadge = UIStackView()
    private let ratingIcon = UIImageView()
    private let ratingLabel = UILabel()
    private let poster = UIImageView()
    private let favoriteButton = UIButton(type: .system)

    private var onFavoriteTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        poster.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
        genresLabel.text = nil
        ratingLabel.text = nil
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardView.alpha = highlighted ? 0.92 : 1
        }
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = AuthTheme.surface
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = AuthTheme.fieldBorder.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 12
        poster.backgroundColor = AuthTheme.background
        poster.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = AuthTheme.textPrimary
        titleLabel.numberOfLines = 2

        metaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        metaLabel.textColor = AuthTheme.textSecondary

        genresLabel.font = .systemFont(ofSize: 13, weight: .regular)
        genresLabel.textColor = AuthTheme.textSecondary
        genresLabel.numberOfLines = 2

        ratingIcon.image = UIImage(systemName: "star.fill")
        ratingIcon.tintColor = AuthTheme.accent
        ratingIcon.contentMode = .scaleAspectFit
        ratingIcon.setContentHuggingPriority(.required, for: .horizontal)
        ratingIcon.setContentHuggingPriority(.required, for: .vertical)
        ratingIcon.setContentCompressionResistancePriority(.required, for: .horizontal)

        ratingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingLabel.textColor = AuthTheme.textPrimary

        ratingBadge.axis = .horizontal
        ratingBadge.spacing = 4
        ratingBadge.alignment = .center
        ratingBadge.isLayoutMarginsRelativeArrangement = true
        ratingBadge.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        ratingBadge.backgroundColor = AuthTheme.accentMuted
        ratingBadge.layer.cornerRadius = 8
        ratingBadge.clipsToBounds = true
        ratingBadge.addArrangedSubview(ratingIcon)
        ratingBadge.addArrangedSubview(ratingLabel)
        ratingBadge.setContentHuggingPriority(.required, for: .horizontal)
        ratingBadge.setContentHuggingPriority(.required, for: .vertical)

        favoriteButton.tintColor = AuthTheme.accent
        favoriteButton.addTarget(self, action: #selector(handleFavoriteTap), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel, genresLabel, ratingBadge])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading
        textStack.setCustomSpacing(10, after: genresLabel)
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(cardView)
        cardView.addSubview(poster)
        cardView.addSubview(textStack)
        cardView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            poster.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            poster.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            poster.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            poster.widthAnchor.constraint(equalToConstant: 88),
            poster.heightAnchor.constraint(equalToConstant: 132),

            textStack.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            favoriteButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    @objc private func handleFavoriteTap() {
        onFavoriteTapped?()
    }

    func configure(
        movie: MovieItem,
        isFavorite: Bool,
        onFavoriteTapped: @escaping () -> Void
    ) {
        self.onFavoriteTapped = onFavoriteTapped

        titleLabel.text = movie.title
        metaLabel.isHidden = false
        metaLabel.text = [movie.year, movie.country].filter { !$0.isEmpty }.joined(separator: " · ")
        genresLabel.text = movie.genres?.joined(separator: " · ")
        genresLabel.isHidden = movie.genres?.isEmpty ?? true
        ratingLabel.text = movie.imdbRating
        ratingBadge.isHidden = movie.imdbRating.isEmpty

        let heartImage = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(
            UIImage(systemName: heartImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)),
            for: .normal
        )

        loadPoster(from: movie.poster)
    }

    func configure(
        favorite: FavoriteMovie,
        onFavoriteTapped: @escaping () -> Void
    ) {
        self.onFavoriteTapped = onFavoriteTapped

        titleLabel.text = favorite.title
        metaLabel.isHidden = false
        metaLabel.text = "Saved to your list"
        genresLabel.isHidden = true
        ratingBadge.isHidden = true

        favoriteButton.setImage(
            UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)),
            for: .normal
        )

        if let data = favorite.poster, let image = UIImage(data: data) {
            poster.image = image
        } else {
            poster.image = nil
            loadPoster(from: favorite.posterURL)
        }
    }

    private func loadPoster(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, error == nil, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.poster.image = image
            }
        }.resume()
    }
}
