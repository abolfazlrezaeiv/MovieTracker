//
//  CategoryCollectionViewCell.swift
//  MovieTracker
//
//  Created by Abolfazl Rezaei on 10/19/25.
//

import UIKit

class GenresCollectionViewCell: UICollectionViewCell {
    
    lazy var container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.4
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        container.addSubview(titleLabel)
        contentView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with genre: Genre) {
        titleLabel.text = genre.name
    }
    
    @objc private func handleButtonTapped() {
    }
}
