//
//  ArticleCell.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import UIKit

class ArticleCell: UITableViewCell {
	static let reuseIdentifier = "ArticleCell"
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.numberOfLines = 0
		return label
	}()
	
	private let bylineLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .subheadline)
		label.textColor = .secondaryLabel
		return label
	}()
	
	private let publishedDateLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .caption1)
		label.textColor = .tertiaryLabel
		return label
	}()
	
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 4
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupViews() {
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(bylineLabel)
		stackView.addArrangedSubview(publishedDateLabel)
		
		contentView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
		])
	}
	
	func configure(with article: Article) {
		titleLabel.text = article.title
		bylineLabel.text = article.byline ?? "No Author"
		publishedDateLabel.text = "Published: \(article.publishedDate)"
	}
}
