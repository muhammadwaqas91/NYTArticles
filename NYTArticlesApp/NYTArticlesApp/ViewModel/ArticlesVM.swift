//
//  ArticlesVM.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//
import Foundation
import RestAPIFramework

/// SRP & OCP

protocol ArticlesFetchable: Equatable {
	var categoryTitle: String { get }
	var period: Period { get }
	func fetchArticles() async throws -> [Article]
}

class ViewedArticlesFetcher: ArticlesFetchable {
	private let networkService: NetworkServiceProtocol
	let period: Period
	let categoryTitle: String = "Most Viewed"
	
	init(networkService: NetworkServiceProtocol, period: Period) {
		self.networkService = networkService
		self.period = period
	}
	
	func fetchArticles() async throws -> [Article] {
		let req = MostPopularArticlesRequest.viewed(period: period)
		let res = try await networkService.execute(request: req) as ArticlesResponse
		return res.results
	}
}

class EmailedArticlesFetcher: ArticlesFetchable {
	private let networkService: NetworkServiceProtocol
	let period: Period
	let categoryTitle: String = "Most Emailed"

	init(networkService: NetworkServiceProtocol, period: Period) {
		self.networkService = networkService
		self.period = period
	}
	
	func fetchArticles() async throws -> [Article] {
		let req = MostPopularArticlesRequest.emailed(period: period)
		let res = try await networkService.execute(request: req) as ArticlesResponse
		return res.results
	}
}

class SharedArticlesFetcher: ArticlesFetchable {
	private let networkService: NetworkServiceProtocol
	let period: Period
	let categoryTitle: String = "Most Shared"
	private let shareType: ShareType
	
	init(networkService: NetworkServiceProtocol, period: Period, shareType: ShareType) {
		self.networkService = networkService
		self.period = period
		self.shareType = shareType
	}
	
	func fetchArticles() async throws -> [Article] {
		let req = MostPopularArticlesRequest.shared(period: period, shareType: shareType)
		let res = try await networkService.execute(request: req) as ArticlesResponse
		return res.results
	}
}

extension ViewedArticlesFetcher: Equatable {
	static func == (lhs: ViewedArticlesFetcher, rhs: ViewedArticlesFetcher) -> Bool {
		return lhs.period == rhs.period
	}
}
extension EmailedArticlesFetcher: Equatable {
	static func == (lhs: EmailedArticlesFetcher, rhs: EmailedArticlesFetcher) -> Bool {
		return lhs.period == rhs.period
	}
}
extension SharedArticlesFetcher: Equatable {
	static func == (lhs: SharedArticlesFetcher, rhs: SharedArticlesFetcher) -> Bool {
		return lhs.period == rhs.period && lhs.shareType == rhs.shareType
	}
}

/// DIP

@MainActor
final class ArticlesVM: ObservableObject {
	@Published var articles: [Article] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	var articlesFetcher: any ArticlesFetchable

	init(articlesFetcher: any ArticlesFetchable) {
		self.articlesFetcher = articlesFetcher
	}
	
	func fetchArticles() async {
		isLoading = true
		errorMessage = nil
		do {
			self.articles = try await articlesFetcher.fetchArticles()
		} catch {
			self.errorMessage = "Error fetching articles: \(error.localizedDescription)"
		}
		isLoading = false
	}
	
	func updateArticlesFetcher(newFetcher: any ArticlesFetchable) async {
		
		articlesFetcher = newFetcher
		await fetchArticles()
	}
}
