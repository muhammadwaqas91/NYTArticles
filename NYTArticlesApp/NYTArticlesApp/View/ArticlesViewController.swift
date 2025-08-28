//
//  ArticlesViewController.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import UIKit
import Combine
import RestAPIFramework

class ArticlesViewController: UIViewController {

	private let tableView = UITableView()
	private let activityIndicator = UIActivityIndicatorView(style: .large)
	private let errorLabel = UILabel()
	
	private let fetcherConfigurations: [(title: String, factory: (NetworkServiceProtocol, Period) -> any ArticlesFetchable)] = [
		("Most Viewed", { network, period in ViewedArticlesFetcher(networkService: network, period: period) }),
		("Most Emailed", { network, period in EmailedArticlesFetcher(networkService: network, period: period) }),
		("Most Shared", { network, period in SharedArticlesFetcher(networkService: network, period: period, shareType: .facebook) })
	]
	
	private lazy var categorySegmentedControl: UISegmentedControl = {
		let items = fetcherConfigurations.map { $0.title }
		let control = UISegmentedControl(items: items)
		control.selectedSegmentIndex = 0
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()
	
	private let periodSegmentedControl: UISegmentedControl = {
		let items = Period.allCases.map { $0.title }
		let control = UISegmentedControl(items: items)
		control.selectedSegmentIndex = 1 // Default to 7 days
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()
	
	private let controlsStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8
		stack.alignment = .fill
		stack.distribution = .fillEqually
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	private let viewModel: ArticlesVM
	private var cancellables = Set<AnyCancellable>()
	
	private let networkService: NetworkServiceProtocol
	
	init(viewModel: ArticlesVM, networkService: NetworkServiceProtocol) {
		self.viewModel = viewModel
		self.networkService = networkService
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		
		if let categoryIndex = fetcherConfigurations.firstIndex(where: { $0.title == viewModel.articlesFetcher.categoryTitle }) {
			categorySegmentedControl.selectedSegmentIndex = categoryIndex
		}
		if let periodIndex = Period.allCases.firstIndex(of: viewModel.articlesFetcher.period) {
			periodSegmentedControl.selectedSegmentIndex = periodIndex
		}

		bindViewModel()
		setupControlActions()
		
		Task {
			await fetchArticles()
		}
	}
	
	private func setupUI() {
		title = "Most Popular Articles"
		view.backgroundColor = .systemBackground
		
		controlsStackView.addArrangedSubview(categorySegmentedControl)
		controlsStackView.addArrangedSubview(periodSegmentedControl)
		view.addSubview(controlsStackView)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseIdentifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		
		errorLabel.textAlignment = .center
		errorLabel.textColor = .systemRed
		errorLabel.numberOfLines = 0
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(errorLabel)
		
		NSLayoutConstraint.activate([
			controlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			controlsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			controlsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			
			tableView.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 8),
			tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			
			errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			errorLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			errorLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
		])
	}
	
	
	private func bindViewModel() {
		viewModel.$articles
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				guard let self else { return }
				self.errorLabel.isHidden = true
				self.tableView.isHidden = false
				self.tableView.reloadData()
			}
			.store(in: &cancellables)
			
		viewModel.$isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				if isLoading {
					self?.activityIndicator.startAnimating()
					self?.tableView.isHidden = true
					self?.errorLabel.isHidden = true
				} else {
					self?.activityIndicator.stopAnimating()
				}
			}
			.store(in: &cancellables)
			
		viewModel.$errorMessage
			.receive(on: DispatchQueue.main)
			.sink { [weak self] message in
				self?.errorLabel.text = message
				self?.errorLabel.isHidden = message == nil
			}
			.store(in: &cancellables)
	}
		
	private func setupControlActions() {
		categorySegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
		periodSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
	}
	
	@objc private func segmentedControlValueChanged() {
		Task {
			await fetchArticles()
		}
	}
	
	private func fetchArticles() async {
		let selectedCategoryIndex = categorySegmentedControl.selectedSegmentIndex
		let selectedPeriod = Period.allCases[periodSegmentedControl.selectedSegmentIndex]
		
		let fetcherFactory = fetcherConfigurations[selectedCategoryIndex].factory
		
		let newFetcher = fetcherFactory(networkService, selectedPeriod)
		
		await viewModel.updateArticlesFetcher(newFetcher: newFetcher)
	}
}

extension ArticlesViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.articles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.reuseIdentifier, for: indexPath) as? ArticleCell else {
			return UITableViewCell()
		}
		let article = viewModel.articles[indexPath.row]
		cell.configure(with: article)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let article = viewModel.articles[indexPath.row]
		
		let detailVC = ArticleDetailViewController(article: article)
		navigationController?.pushViewController(detailVC, animated: true)
	}
}
