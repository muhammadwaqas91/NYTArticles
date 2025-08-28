//
//  SceneDelegate.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import UIKit
import RestAPIFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: windowScene)
		
		let networkService = NetworkService()
		let initialFetcher = ViewedArticlesFetcher(networkService: networkService, period: .sevenDays)
		
		let articlesViewModel = ArticlesVM(articlesFetcher: initialFetcher)
		let articlesVC = ArticlesViewController(viewModel: articlesViewModel, networkService: networkService)
		
		
		let navigationController = UINavigationController(rootViewController: articlesVC)
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
}
