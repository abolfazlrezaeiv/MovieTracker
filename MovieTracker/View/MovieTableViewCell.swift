//
//  MovieCustomCell.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/17/25.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let countryLabel = UILabel()
    let yearLabel = UILabel()
    let rateLabel = UILabel()
    let genresLabel = UILabel()
    let poster = UIImageView()
    let infoStack = UIStackView()
    let favotiteIcon = UIImageView()
    
    private var onFavoriteTapped: (() -> Void)?
    
    @objc private func handleFavoriteTap() {
        onFavoriteTapped?()
    }

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(poster)
        contentView.addSubview(infoStack)
        contentView.addSubview(favotiteIcon)
        
        favotiteIcon.tintColor = .systemRed
        favotiteIcon.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFavoriteTap)
        )
        favotiteIcon.addGestureRecognizer(tap)
        
        poster.translatesAutoresizingMaskIntoConstraints = false
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        favotiteIcon.translatesAutoresizingMaskIntoConstraints = false
        
        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 8
        
        infoStack.axis = .vertical
        infoStack.spacing = 1
        infoStack.addArrangedSubview(titleLabel)
        infoStack.addArrangedSubview(yearLabel)
        infoStack.addArrangedSubview(countryLabel)
        infoStack.addArrangedSubview(genresLabel)
        infoStack.addArrangedSubview(rateLabel)
        
        NSLayoutConstraint.activate([
            poster.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 15),
            poster.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            poster.widthAnchor.constraint(equalToConstant: 120),
            poster.heightAnchor.constraint(equalToConstant: 120),
            poster.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 12),
            poster.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            
            infoStack.leadingAnchor
                .constraint(equalTo: poster.trailingAnchor, constant: 10),
            infoStack.centerYAnchor
                .constraint(equalTo: poster.centerYAnchor),
            infoStack.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -15),
            infoStack.topAnchor
                .constraint(equalTo: contentView.topAnchor,constant: 12),
            infoStack.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor,constant: -8),
            favotiteIcon.trailingAnchor
                .constraint(equalTo:  contentView.trailingAnchor,constant: -12),
            favotiteIcon.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor,constant: -12),
            favotiteIcon.widthAnchor.constraint(equalToConstant: 20),
            favotiteIcon.heightAnchor.constraint(equalToConstant: 20)
            
        ])
    }
 
    func configure(
        movie: MovieItem,
        isFavorite: Bool,
        onFavoriteTapped: @escaping () -> Void
    ) {
        self.onFavoriteTapped = onFavoriteTapped
        
        titleLabel.text = movie.title
        countryLabel.text = movie.country
        yearLabel.text = movie.year
        rateLabel.text = movie.imdbRating
        genresLabel.text = movie.genres?.joined(separator: ", ")
        favotiteIcon.image = UIImage(systemName: !isFavorite ? "heart" : "heart.fill")
        
        guard let url = URL(string: movie.poster) else {
            return
        }
        URLSession.shared
            .dataTask(
                with: url,
                completionHandler: { data,response,error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("##### \(error)")
                            return
                        }
                        
                        if let data = data {
                            self.poster.image = UIImage(data: data)
                        }
                    }
                }
            ).resume()
    }
}
