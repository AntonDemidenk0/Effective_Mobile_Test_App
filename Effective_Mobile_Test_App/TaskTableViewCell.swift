//
//  TaskTableViewCell.swift
//  Effective_Mobile_Test_App
//
//  Created by Anton Demidenko on 30.1.25..
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    static let identifier = "TaskTableViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "white")
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "white")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creationDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "white")
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(creationDateLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            creationDateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            creationDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            creationDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            creationDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with task: toDoTask) {
        let iconName = task.isReady ? "done" : "undone"
        iconImageView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = task.isReady ? .yellow : .gray
        
        let textAlpha: CGFloat = task.isReady ? 0.5 : 1.0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(textAlpha),
            .strikethroughStyle: task.isReady ? NSUnderlineStyle.single.rawValue : 0
        ]
        
        titleLabel.attributedText = NSAttributedString(string: task.title, attributes: attributes)
        descriptionLabel.text = task.description
        descriptionLabel.alpha = textAlpha
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: task.creationDate) {
            creationDateLabel.text = dateFormatter.string(from: date)
        } else {
            creationDateLabel.text = task.creationDate
        }
    }
}
