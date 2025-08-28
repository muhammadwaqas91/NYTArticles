//
//  AppDelegate.swift
//  NYTArticlesApp
//
//  Created by Muhammad Waqas on 28/08/25.
//

import UIKit
import RestAPIFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
			
		window = UIWindow(frame: UIScreen.main.bounds)
		let networkService = NetworkService()
		let initialFetcher = ViewedArticlesFetcher(networkService: networkService, period: .sevenDays)
		
		let articlesViewModel = ArticlesVM(articlesFetcher: initialFetcher)
		let articlesVC = ArticlesViewController(viewModel: articlesViewModel, networkService: networkService)
		let navigationController = UINavigationController(rootViewController: articlesVC)

		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
}
